import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../cubit/lang_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/injection_container.dart';
import '../../features/notifications/data/models/notification_box_entity.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    // Initialize Timezones
    tz.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    
    // Local Notifications Setup
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _navigateToNotifications();
      },
    );

    // Register Notification Channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
    }

    // Set FCM Foreground Options
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Request Permissions
    await _requestPermissions();

    // Subscribe to global topic
    await _fcm.subscribeToTopic('all_users');

    // FCM Foreground Handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null && !kIsWeb) {
        _handleIncomingNotification(
          notification.title,
          notification.body,
          message.data['type'] ?? 'system',
        );
      }
    });

    // FCM Background/Terminated Opening Handling
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _saveRemoteMessageToLocal(message);
      _navigateToNotifications();
    });

    // Check for initial message (when app is opened from terminated state via notification)
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _saveRemoteMessageToLocal(initialMessage);
      _navigateToNotifications();
    }
  }

  void _saveRemoteMessageToLocal(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    final title = notification?.title ?? message.data['title'] ?? message.data['titleEn'] ?? message.data['titleAr'];
    final body = notification?.body ?? message.data['body'] ?? message.data['bodyEn'] ?? message.data['bodyAr'];
    final type = message.data['type'] ?? 'system';

    if (title != null || body != null) {
      InjectionContainer.objectBoxService.saveNotification(NotificationBoxEntity(
        titleEn: title ?? '',
        titleAr: title ?? '',
        bodyEn: body ?? '',
        bodyAr: body ?? '',
        type: type,
        timestamp: message.sentTime ?? DateTime.now(),
      ));

      try {
        InjectionContainer.notificationsCubit.loadNotifications();
      } catch (_) {}
    }
  }

  void _navigateToNotifications() {
    if (TrueFitApp.navigatorKey.currentState != null) {
      final context = TrueFitApp.navigatorKey.currentContext!;
      final lang = BlocProvider.of<LangCubit>(context).state;
      TrueFitApp.navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => NotificationsScreen(lang: lang)),
      );
    }
  }

  Future<void> _handleIncomingNotification(String? title, String? body, String type) async {
    final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    // Save to ObjectBox
    InjectionContainer.objectBoxService.saveNotification(NotificationBoxEntity(
      titleEn: title ?? '',
      titleAr: title ?? '',
      bodyEn: body ?? '',
      bodyAr: body ?? '',
      type: type,
      timestamp: DateTime.now(),
    ));

    // Refresh UI if screen is open (via Cubit)
    try {
      InjectionContainer.notificationsCubit.loadNotifications();
    } catch (_) {}

    await _showLocalNotification(id, title, body);
  }

  Future<void> _showLocalNotification(int id, String? title, String? body) async {
    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<bool> _requestPermissions() async {
    try {
      if (kIsWeb) return false;

      // FCM Permissions
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      // Local Notifications Permissions
      if (Platform.isAndroid) {
        final androidImplementation = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          await androidImplementation.requestNotificationsPermission();
        }
      } else if (Platform.isIOS) {
        final iosImplementation = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        if (iosImplementation != null) {
          await iosImplementation.requestPermissions(alert: true, badge: true, sound: true);
        }
      }
      return true;
    } catch (e) {
      debugPrint("Error requesting permissions: $e");
      return false;
    }
  }

  Future<void> sendWelcomeNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstTime = prefs.getBool('first_time_notification') ?? true;

    if (isFirstTime) {
      final context = TrueFitApp.navigatorKey.currentContext;
      final lang = context != null ? BlocProvider.of<LangCubit>(context).state : 'en';

      final String title = lang == 'ar' ? 'مرحباً بك في True Fit!' : 'Welcome to True Fit!';
      final String body = lang == 'ar' 
          ? 'نحن سعداء بانضمامك إلينا. ابدأ رحلة لياقتك اليوم!' 
          : 'We are excited to have you with us. Start your fitness journey today!';
      
      await _handleIncomingNotification(title, body, 'system');
      await prefs.setBool('first_time_notification', false);
    }
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  Future<String?> getFCMToken() async {
    return await _fcm.getToken();
  }
}
