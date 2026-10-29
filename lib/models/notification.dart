enum NotificationType { grade, discount, payment, salary, announcement, general }

class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type.name,
    'title': title,
    'message': message,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'] as String,
    userId: json['userId'] as String,
    type: NotificationType.values.firstWhere((e) => e.name == json['type']),
    title: json['title'] as String,
    message: json['message'] as String,
    isRead: json['isRead'] as bool,
    createdAt: DateTime.parse(json['createdAt']),
  );

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
  }) => AppNotification(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    type: type ?? this.type,
    title: title ?? this.title,
    message: message ?? this.message,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt ?? this.createdAt,
  );
}
