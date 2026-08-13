import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/continue_as_guest_usecase.dart';
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import '../../features/notifications/domain/usecases/mark_all_read_usecase.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/usecases/get_home_data_usecase.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/booking/data/datasources/booking_remote_datasource.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/domain/usecases/get_pt_sessions_usecase.dart';
import '../../features/booking/domain/usecases/get_group_classes_usecase.dart';
import '../../features/booking/domain/usecases/book_session_usecase.dart';
import '../../features/booking/domain/usecases/get_coaches_usecase.dart';
import '../../features/booking/domain/usecases/get_pt_offers_usecase.dart';
import '../../features/booking/domain/usecases/buy_pt_package_usecase.dart';
import '../../features/booking/domain/usecases/schedule_pt_session_usecase.dart';
import '../../features/booking/domain/usecases/watch_user_bookings_usecase.dart';
import '../../features/booking/domain/usecases/watch_coach_availability_usecase.dart';
import '../../features/booking/domain/usecases/watch_user_pt_wallet_usecase.dart';
import '../../features/booking/presentation/cubit/booking_cubit.dart';
import '../../features/diet/data/datasources/diet_remote_datasource.dart';
import '../../features/diet/data/repositories/diet_repository_impl.dart';
import '../../features/diet/domain/usecases/get_diet_plan_usecase.dart';
import '../../features/diet/domain/usecases/update_water_intake_usecase.dart';
import '../../features/diet/presentation/cubit/diet_cubit.dart';
import '../../features/progress/data/datasources/progress_remote_datasource.dart';
import '../../features/progress/data/repositories/progress_repository_impl.dart';
import '../../features/progress/domain/usecases/get_progress_usecase.dart';
import '../../features/progress/domain/usecases/book_inbody_scan_usecase.dart';
import '../../features/progress/presentation/cubit/progress_cubit.dart';
import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/usecases/get_conversations_usecase.dart';
import '../../features/chat/domain/usecases/get_messages_usecase.dart';
import '../../features/chat/domain/usecases/send_message_usecase.dart';
import '../../features/chat/presentation/cubit/chat_cubit.dart';
import '../../features/subscription/data/datasources/subscription_remote_datasource.dart';
import '../../features/subscription/data/repositories/subscription_repository_impl.dart';
import '../../features/subscription/domain/usecases/get_membership_plans_usecase.dart';
import '../../features/subscription/domain/usecases/subscribe_usecase.dart';
import '../../features/subscription/presentation/cubit/subscription_cubit.dart';
import '../services/objectbox_service.dart';

class InjectionContainer {
  static AuthCubit? _authCubit;
  static ProfileCubit? _profileCubit;
  static NotificationsCubit? _notificationsCubit;
  static HomeCubit? _homeCubit;
  static BookingCubit? _bookingCubit;
  static DietCubit? _dietCubit;
  static ProgressCubit? _progressCubit;
  static ChatCubit? _chatCubit;
  static SubscriptionCubit? _subscriptionCubit;
  static ObjectBoxService? _objectBoxService;

  static AuthCubit get authCubit => _authCubit!;
  static ProfileCubit get profileCubit => _profileCubit!;
  static NotificationsCubit get notificationsCubit => _notificationsCubit!;
  static HomeCubit get homeCubit => _homeCubit!;
  static BookingCubit get bookingCubit => _bookingCubit!;
  static DietCubit get dietCubit => _dietCubit!;
  static ProgressCubit get progressCubit => _progressCubit!;
  static ChatCubit get chatCubit => _chatCubit!;
  static SubscriptionCubit get subscriptionCubit => _subscriptionCubit!;
  static ObjectBoxService get objectBoxService => _objectBoxService!;

  static Future<void> init() async {
    // Services
    _objectBoxService = await ObjectBoxService.create();

    // Data sources
    final authRemoteDataSource = AuthRemoteDataSourceImpl();
    final profileRemoteDataSource = ProfileRemoteDataSourceImpl();
    final notificationRemoteDataSource = NotificationRemoteDataSourceImpl();
    final homeRemoteDataSource = HomeRemoteDataSourceImpl();
    final bookingRemoteDataSource = BookingRemoteDataSourceImpl();
    final dietRemoteDataSource = DietRemoteDataSourceImpl();
    final progressRemoteDataSource = ProgressRemoteDataSourceImpl();
    final chatRemoteDataSource = ChatRemoteDataSourceImpl();
    final subscriptionRemoteDataSource = SubscriptionRemoteDataSourceImpl();

    // Repositories
    final authRepository = AuthRepositoryImpl(authRemoteDataSource);
    final profileRepository = ProfileRepositoryImpl(profileRemoteDataSource);
    final notificationRepository = NotificationRepositoryImpl(notificationRemoteDataSource);
    final homeRepository = HomeRepositoryImpl(homeRemoteDataSource);
    final bookingRepository = BookingRepositoryImpl(bookingRemoteDataSource);
    final dietRepository = DietRepositoryImpl(dietRemoteDataSource);
    final progressRepository = ProgressRepositoryImpl(progressRemoteDataSource);
    final chatRepository = ChatRepositoryImpl(chatRemoteDataSource);
    final subscriptionRepository = SubscriptionRepositoryImpl(subscriptionRemoteDataSource);

    // Use cases
    final loginUseCase = LoginUseCase(authRepository);
    final registerUseCase = RegisterUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);
    final continueAsGuestUseCase = ContinueAsGuestUseCase(authRepository);
    final checkAuthStatusUseCase = CheckAuthStatusUseCase(authRepository);

    final getProfileUseCase = GetProfileUseCase(profileRepository);
    final updateProfileUseCase = UpdateProfileUseCase(profileRepository);

    final getNotificationsUseCase = GetNotificationsUseCase(notificationRepository);
    final markNotificationReadUseCase = MarkNotificationReadUseCase(notificationRepository);
    final markAllReadUseCase = MarkAllReadUseCase(notificationRepository);

    final getHomeDataUseCase = GetHomeDataUseCase(homeRepository);

    final getPTSessionsUseCase = GetPTSessionsUseCase(bookingRepository);
    final getGroupClassesUseCase = GetGroupClassesUseCase(bookingRepository);
    final bookSessionUseCase = BookSessionUseCase(bookingRepository);
    final getCoachesUseCase = GetCoachesUseCase(bookingRepository);
    final getPTOffersUseCase = GetPTOffersUseCase(bookingRepository);
    final buyPTPackageUseCase = BuyPTPackageUseCase(bookingRepository);
    final schedulePTSessionUseCase = SchedulePTSessionUseCase(bookingRepository);
    final watchUserBookingsUseCase = WatchUserBookingsUseCase(bookingRepository);
    final watchCoachAvailabilityUseCase = WatchCoachAvailabilityUseCase(bookingRepository);
    final watchUserPTWalletUseCase = WatchUserPTWalletUseCase(bookingRepository);

    final getDietPlanUseCase = GetDietPlanUseCase(dietRepository);
    final updateWaterIntakeUseCase = UpdateWaterIntakeUseCase(dietRepository);

    final getProgressUseCase = GetProgressUseCase(progressRepository);
    final bookInBodyScanUseCase = BookInBodyScanUseCase(progressRepository);

    final getConversationsUseCase = GetConversationsUseCase(chatRepository);
    final getMessagesUseCase = GetMessagesUseCase(chatRepository);
    final sendMessageUseCase = SendMessageUseCase(chatRepository);

    final getMembershipPlansUseCase = GetMembershipPlansUseCase(subscriptionRepository);
    final subscribeUseCase = SubscribeUseCase(subscriptionRepository);

    // Cubits
    _authCubit = AuthCubit(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      logoutUseCase: logoutUseCase,
      continueAsGuestUseCase: continueAsGuestUseCase,
      checkAuthStatusUseCase: checkAuthStatusUseCase,
    );

    _profileCubit = ProfileCubit(
      getProfileUseCase: getProfileUseCase,
      updateProfileUseCase: updateProfileUseCase,
    );

    _notificationsCubit = NotificationsCubit(
      getNotificationsUseCase: getNotificationsUseCase,
      markNotificationReadUseCase: markNotificationReadUseCase,
      markAllReadUseCase: markAllReadUseCase,
    );

    _homeCubit = HomeCubit(
      getHomeDataUseCase: getHomeDataUseCase,
    );

    _bookingCubit = BookingCubit(
      getCoachesUseCase: getCoachesUseCase,
      getPTOffersUseCase: getPTOffersUseCase,
      getGroupClassesUseCase: getGroupClassesUseCase,
      buyPTPackageUseCase: buyPTPackageUseCase,
      schedulePTSessionUseCase: schedulePTSessionUseCase,
      watchUserBookingsUseCase: watchUserBookingsUseCase,
      watchUserPTWalletUseCase: watchUserPTWalletUseCase,
      watchCoachAvailabilityUseCase: watchCoachAvailabilityUseCase,
      bookSessionUseCase: bookSessionUseCase,
    );

    _dietCubit = DietCubit(
      getDietPlanUseCase: getDietPlanUseCase,
      updateWaterIntakeUseCase: updateWaterIntakeUseCase,
    );

    _progressCubit = ProgressCubit(
      getProgressUseCase: getProgressUseCase,
      bookInBodyScanUseCase: bookInBodyScanUseCase,
    );

    _chatCubit = ChatCubit(
      getConversationsUseCase: getConversationsUseCase,
      getMessagesUseCase: getMessagesUseCase,
      sendMessageUseCase: sendMessageUseCase,
    );

    _subscriptionCubit = SubscriptionCubit(
      getMembershipPlansUseCase: getMembershipPlansUseCase,
      subscribeUseCase: subscribeUseCase,
    );
  }

  static void clearAllData() {
    _authCubit?.reset();
    _profileCubit?.reset();
    _notificationsCubit?.reset();
    _homeCubit?.reset();
    _bookingCubit?.reset();
    _dietCubit?.reset();
    _progressCubit?.reset();
    _chatCubit?.reset();
    _subscriptionCubit?.reset();
  }
}
