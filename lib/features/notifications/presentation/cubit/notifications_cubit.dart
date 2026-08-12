import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../../domain/usecases/mark_all_read_usecase.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;
  final MarkAllReadUseCase markAllReadUseCase;

  NotificationsCubit({
    required this.getNotificationsUseCase,
    required this.markNotificationReadUseCase,
    required this.markAllReadUseCase,
  }) : super(NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(NotificationsLoading());
    try {
      final notifications = await getNotificationsUseCase(NoParams());
      emit(NotificationsLoaded(List.from(notifications)));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> markRead(String id) async {
    try {
      await markNotificationReadUseCase(id);
      final currentState = state;
      if (currentState is NotificationsLoaded) {
        final updatedList = currentState.notifications.map((n) {
          if (n.id == id) {
            return n.copyWith(read: true);
          }
          return n;
        }).toList();
        emit(NotificationsLoaded(updatedList));
      }
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> markAllRead() async {
    try {
      await markAllReadUseCase(NoParams());
      final currentState = state;
      if (currentState is NotificationsLoaded) {
        final updatedList = currentState.notifications.map((n) => n.copyWith(read: true)).toList();
        emit(NotificationsLoaded(updatedList));
      }
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  void reset() {
    emit(NotificationsInitial());
  }
}
