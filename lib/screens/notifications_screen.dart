import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:course_users/widgets/paginated_list_view.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              if (userId == null) return;
              await Supabase.instance.client
                  .from('notifications')
                  .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
                  .eq('user_id', userId)
                  .eq('is_read', false);
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: PaginatedListView<Map<String, dynamic>>(
        fetcher: (page, pageSize) async {
          final data = await Supabase.instance.client
              .from('notifications')
              .select('*')
              .eq('user_id', userId ?? '')
              .order('created_at', ascending: false)
              .range(page * pageSize, page * pageSize + pageSize - 1);
          return List<Map<String, dynamic>>.from(data);
        },
        skeleton: (context) => const SkeletonListPage(itemCount: 8),
        empty: (context, _) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_none_rounded,
                  size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No notifications',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
        itemBuilder: (context, n, index) {
          final isRead = n['is_read'] == true;
          final type = n['type']?.toString() ?? 'general';
          final createdAt = n['created_at']?.toString();

          return Card(
            color: isRead
                ? null
                : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _typeColor(type).withValues(alpha: 0.15),
                child: Icon(_typeIcon(type), color: _typeColor(type), size: 20),
              ),
              title: Text(
                n['title']?.toString() ?? 'Notification',
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (n['body'] != null) Text(n['body'].toString()),
                  if (createdAt != null)
                    Text(
                      DateFormat.yMMMd().add_jm().format(DateTime.parse(createdAt)),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
              onTap: () async {
                if (!isRead && n['id'] != null) {
                  await Supabase.instance.client.from('notifications').update({
                    'is_read': true,
                    'read_at': DateTime.now().toIso8601String(),
                  }).eq('id', n['id']);
                }
              },
            ),
          );
        },
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'payment':
        return Icons.payment_rounded;
      case 'attendance':
        return Icons.check_circle_rounded;
      case 'exam':
        return Icons.quiz_rounded;
      case 'message':
        return Icons.message_rounded;
      case 'leave':
        return Icons.event_busy_rounded;
      case 'library':
        return Icons.library_books_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'payment':
        return Colors.black87;
      case 'attendance':
        return Colors.black87;
      case 'exam':
        return Colors.purple;
      case 'message':
        return Colors.black87;
      case 'leave':
        return Colors.orange;
      default:
        return Colors.black87;
    }
  }
}
