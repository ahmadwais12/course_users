import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:course_users/models/notification.dart';
import 'package:course_users/repositories/notification_repository.dart';

final notificationRepositoryProvider =
    Provider((ref) => NotificationRepository());

final notificationNotifierProvider = StateNotifierProvider<NotificationNotifier,
    AsyncValue<List<AppNotification>>>((ref) {
  return NotificationNotifier(ref.read(notificationRepositoryProvider));
});

class NotificationNotifier
    extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final NotificationRepository _repository;

  NotificationNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getAll();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addNotification(AppNotification notification) async {
    await _repository.create(notification);
    await loadNotifications();
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    await loadNotifications();
  }

  Future<void> deleteNotification(String id) async {
    await _repository.delete(id);
    await loadNotifications();
  }
}
