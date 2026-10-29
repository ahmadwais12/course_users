import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:course_users/widgets/paginated_list_view.dart';

/// Digital library resources from [digital_library] table.
class DigitalLibraryScreen extends ConsumerWidget {
  const DigitalLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Library'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PaginatedListView<Map<String, dynamic>>(
        fetcher: (page, pageSize) async {
          final data = await Supabase.instance.client
              .from('digital_library')
              .select('*')
              .order('created_at', ascending: false)
              .range(page * pageSize, page * pageSize + pageSize - 1);
          return List<Map<String, dynamic>>.from(data);
        },
        skeleton: (context) => const SkeletonListPage(itemCount: 8),
        empty: (context, _) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_rounded, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No digital resources available',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
        itemBuilder: (context, item, index) {
          final type = item['type']?.toString() ?? 'E-Book';
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: Icon(_typeIcon(type), color: Colors.black87),
              ),
              title: Text(item['title']?.toString() ?? 'Untitled'),
              subtitle: Text(
                '${item['author'] ?? 'Unknown'} • $type',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: item['download_enabled'] == true
                  ? const Icon(Icons.download_rounded)
                  : const Icon(Icons.visibility_rounded),
            ),
          ).animate().fadeIn(delay: (index * 50).ms);
        },
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Video':
        return Icons.video_library_rounded;
      case 'Audio':
        return Icons.audiotrack_rounded;
      case 'Journal':
      case 'Article':
        return Icons.article_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }
}

/// Student documents from [student_documents] table.
class StudentDocumentsScreen extends ConsumerWidget {
  const StudentDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Documents'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PaginatedListView<Map<String, dynamic>>(
        fetcher: (page, pageSize) async {
          final data = await Supabase.instance.client
              .from('student_documents')
              .select('*')
              .eq('student_id', userId ?? '')
              .order('created_at', ascending: false)
              .range(page * pageSize, page * pageSize + pageSize - 1);
          return List<Map<String, dynamic>>.from(data);
        },
        skeleton: (context) => const SkeletonListPage(itemCount: 6),
        empty: (context, _) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_off_rounded, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No documents uploaded',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
        itemBuilder: (context, doc, index) {
          final type = doc['document_type']?.toString() ?? 'other';
          final verified = doc['is_verified'] == true;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(_docIcon(type), color: Colors.grey),
              title: Text(type.replaceAll('_', ' ').toUpperCase()),
              subtitle: Text(
                'Issued: ${doc['issue_date'] ?? 'N/A'}${doc['expiry_date'] != null ? ' • Expires: ${doc['expiry_date']}' : ''}',
              ),
              trailing: verified
                  ? const Icon(Icons.verified_rounded, color: Colors.black87)
                  : const Icon(Icons.pending_rounded, color: Colors.orange),
            ),
          );
        },
      ),
    );
  }

  IconData _docIcon(String type) {
    switch (type) {
      case 'id_card':
        return Icons.badge_rounded;
      case 'transcript':
      case 'report_card':
        return Icons.description_rounded;
      case 'certificate':
        return Icons.workspace_premium_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}

/// Student leave applications from [student_leaves] table.
class StudentLeaveScreen extends ConsumerStatefulWidget {
  const StudentLeaveScreen({super.key});

  @override
  ConsumerState<StudentLeaveScreen> createState() => _StudentLeaveScreenState();
}

class _StudentLeaveScreenState extends ConsumerState<StudentLeaveScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitLeave() async {
    if (_startDate == null || _endDate == null) return;
    setState(() => _submitting = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      await Supabase.instance.client.from('student_leaves').insert({
        'student_id': userId,
        'start_date': _startDate!.toIso8601String().split('T').first,
        'end_date': _endDate!.toIso8601String().split('T').first,
        'reason': _reasonController.text.trim(),
        'status': 'pending',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave application submitted')),
        );
        setState(() {
          _startDate = null;
          _endDate = null;
          _reasonController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Applications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: PaginatedListView<Map<String, dynamic>>(
              fetcher: (page, pageSize) async {
                final data = await Supabase.instance.client
                    .from('student_leaves')
                    .select('*')
                    .eq('student_id', userId ?? '')
                    .order('created_at', ascending: false)
                    .range(page * pageSize, page * pageSize + pageSize - 1);
                return List<Map<String, dynamic>>.from(data);
              },
              skeleton: (context) => const SkeletonListPage(itemCount: 5),
              empty: (context, _) =>
                  const Center(child: Text('No leave applications yet')),
              itemBuilder: (context, leave, index) {
                final status = leave['status']?.toString() ?? 'pending';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      '${leave['start_date']} → ${leave['end_date']}',
                    ),
                    subtitle: Text(leave['reason']?.toString() ?? ''),
                    trailing: Chip(
                      label: Text(status),
                      backgroundColor: _statusColor(status),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) setState(() => _startDate = date);
                        },
                        child: Text(_startDate == null
                            ? 'Start Date'
                            : DateFormat.yMMMd().format(_startDate!)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: _startDate ?? DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) setState(() => _endDate = date);
                        },
                        child: Text(_endDate == null
                            ? 'End Date'
                            : DateFormat.yMMMd().format(_endDate!)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _submitting ? null : _submitLeave,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Apply for Leave'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.grey.shade300;
      case 'rejected':
        return Colors.red.shade100;
      case 'cancelled':
        return Colors.grey.shade200;
      default:
        return Colors.orange.shade100;
    }
  }
}

/// Parent invoices from [invoices] table.
class ParentInvoicesScreen extends ConsumerWidget {
  const ParentInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PaginatedListView<Map<String, dynamic>>(
        fetcher: (page, pageSize) async {
          final data = await Supabase.instance.client
              .from('invoices')
              .select('*')
              .order('issue_date', ascending: false)
              .range(page * pageSize, page * pageSize + pageSize - 1);
          return List<Map<String, dynamic>>.from(data);
        },
        skeleton: (context) => const SkeletonListPage(itemCount: 8),
        empty: (context, _) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No invoices found',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
        itemBuilder: (context, invoice, index) {
          final status = invoice['status']?.toString() ?? 'Pending';
          final amount = (invoice['total_amount'] as num? ??
                  invoice['amount'] as num? ??
                  0)
              .toDouble();
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _invoiceColor(status).withValues(alpha: 0.2),
                child: Icon(Icons.receipt, color: _invoiceColor(status)),
              ),
              title: Text(invoice['invoice_number']?.toString() ?? 'Invoice'),
              subtitle: Text(
                'Due: ${invoice['due_date'] ?? 'N/A'} • ${invoice['description'] ?? ''}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(status, style: TextStyle(color: _invoiceColor(status))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _invoiceColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.black87;
      case 'Overdue':
        return Colors.red;
      case 'Cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}

/// About the EMIS platform.
class AboutEmisScreen extends StatelessWidget {
  const AboutEmisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About EMIS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(Icons.school_rounded,
              size: 72, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Course EMIS',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Education Management Information System for students and parents.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 32),
          _AboutTile(
            icon: Icons.auto_stories_rounded,
            title: 'Academic Tracking',
            subtitle: 'Courses, grades, exams, and attendance in one place.',
          ),
          _AboutTile(
            icon: Icons.family_restroom_rounded,
            title: 'Parent Portal',
            subtitle: 'Monitor children progress, fees, and school communication.',
          ),
          _AboutTile(
            icon: Icons.security_rounded,
            title: 'Secure & Private',
            subtitle: 'Role-based access backed by Supabase authentication.',
          ),
        ],
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AboutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

/// Unified messages hub using [parent_messages] and [chat_messages].
class MessagesHubScreen extends ConsumerWidget {
  const MessagesHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    final role =
        supabase.auth.currentUser?.userMetadata?['role']?.toString().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PaginatedListView<Map<String, dynamic>>(
        fetcher: (page, pageSize) async {
          final base = role == 'parent'
              ? supabase
                  .from('parent_messages')
                  .select('*')
                  .eq('parent_id', userId ?? '')
                  .order('created_at', ascending: false)
              : supabase
                  .from('chat_messages')
                  .select('*, chat_groups(name, type)')
                  .eq('sender_id', userId ?? '')
                  .order('created_at', ascending: false);
          final data = await base
              .range(page * pageSize, page * pageSize + pageSize - 1);
          return List<Map<String, dynamic>>.from(data);
        },
        skeleton: (context) => const SkeletonListPage(itemCount: 8),
        empty: (context, _) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mail_outline_rounded, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No messages yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
        itemBuilder: (context, msg, index) {
          final title = role == 'parent'
              ? (msg['subject']?.toString() ?? 'Message')
              : (msg['chat_groups']?['name']?.toString() ?? 'Chat');
          final body = role == 'parent'
              ? msg['message']?.toString()
              : msg['content']?.toString();
          final date = msg['created_at']?.toString();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(title),
              subtitle: Text(
                body ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: date != null
                  ? Text(
                      DateFormat.MMMd().format(DateTime.parse(date)),
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
