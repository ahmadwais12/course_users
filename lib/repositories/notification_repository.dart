import 'dart:convert';
import 'package:course_users/models/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRepository {
  final List<AppNotification> _cache = [];
  static const _storageKey = 'app_notifications';

  Future<void> _loadIfNeeded() async {
    if (_cache.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];
    for (final item in jsonList) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      _cache.add(AppNotification.fromJson(map));
    }
    _cache.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _cache.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_storageKey, list);
  }

  Future<List<AppNotification>> getAll() async {
    await _loadIfNeeded();
    return List.from(_cache);
  }
  Future<List<AppNotification>> getByUser(String userId) async => 
    (await getAll()).where((n) => n.userId == userId).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  
  Future<void> create(AppNotification notification) async {
    _cache.add(notification);
    await _persist();
  }

  Future<void> markAsRead(String id) async {
    final index = _cache.indexWhere((n) => n.id == id);
    if (index != -1) {
      _cache[index] = _cache[index].copyWith(isRead: true);
      await _persist();
    }
  }

  Future<void> delete(String id) async {
    _cache.removeWhere((n) => n.id == id);
    await _persist();
  }
}
