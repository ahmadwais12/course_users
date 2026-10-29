import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

typedef NotificationTapCallback = void Function(RemoteMessage message);

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  bool _initialized = false;
  NotificationTapCallback? onTap;

  Future<void> init({NotificationTapCallback? onTap}) async {
    if (_initialized) return;
    this.onTap = onTap;
    await Firebase.initializeApp();
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    await messaging.getToken();
    _initialized = true;
  }

  void _onForegroundMessage(RemoteMessage message) {
    _storeLocal(message);
    final navigatorKey = GlobalKey<NavigatorState>();
    final context = navigatorKey.currentContext;
    if (context != null) {
      final title = message.notification?.title ?? 'Notification';
      final body = message.notification?.body ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title: $body')),
      );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    if (onTap != null) onTap!(message);
  }

  Future<void> _storeLocal(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'app_notifications';
    final list = prefs.getStringList(key) ?? [];
    final id = const Uuid().v4();
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';
    final data = {
      'id': id,
      'userId': message.data['userId'] ?? '',
      'type': 'general',
      'title': title,
      'message': body,
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
    list.insert(0, jsonEncode(data));
    await prefs.setStringList(key, list);
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  final key = 'app_notifications';
  final list = prefs.getStringList(key) ?? [];
  final id = const Uuid().v4();
  final title = message.notification?.title ?? 'Notification';
  final body = message.notification?.body ?? '';
  final data = {
    'id': id,
    'userId': message.data['userId'] ?? '',
    'type': 'general',
    'title': title,
    'message': body,
    'isRead': false,
    'createdAt': DateTime.now().toIso8601String(),
  };
  list.insert(0, jsonEncode(data));
  await prefs.setStringList(key, list);
}
