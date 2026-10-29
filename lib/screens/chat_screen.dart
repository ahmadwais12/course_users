import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:course_users/providers/chat_providers.dart';
import 'package:course_users/widgets/paginated_list_view.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGroups = ref.watch(chatGroupsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: asyncGroups.when(
        data: (groups) {
          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  const SizedBox(height: 16),
                  Text('No conversations yet',
                      style: TextStyle(
                          fontSize: 18,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final preview = group.lastMessage?.content ?? 'No messages yet';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(
                      group.type == 'direct'
                          ? Icons.person_rounded
                          : Icons.group_rounded,
                      color: Colors.black87,
                    ),
                  ),
                  title: Text(group.name),
                  subtitle: Text(
                    group.description ?? preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: group.lastMessage != null
                      ? Text(
                          _formatTime(group.lastMessage!.createdAt),
                          style: theme.textTheme.bodySmall,
                        )
                      : null,
                  onTap: () => context.push('/chat/${group.id}'),
                ),
              );
            },
          );
        },
        loading: () => const SkeletonListPage(itemCount: 8),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays}d';
    if (difference.inHours > 0) return '${difference.inHours}h';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m';
    return 'now';
  }
}
