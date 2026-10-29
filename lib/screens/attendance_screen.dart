import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:course_users/models/attendance.dart';
import 'package:course_users/providers/attendance_provider.dart';
import 'package:course_users/widgets/modern_ui.dart';
import 'package:course_users/widgets/skeleton_loader.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(attendanceNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const ModernAppBar(title: 'Attendance', hasGradient: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMarkDialog(context, ref),
        icon: const Icon(Icons.check_circle),
        label: const Text('Mark Attendance'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                children: [
                  _FilterChip('All', _filter == 'All',
                      () => setState(() => _filter = 'All')),
                  _FilterChip('Present', _filter == 'Present',
                      () => setState(() => _filter = 'Present')),
                  _FilterChip('Absent', _filter == 'Absent',
                      () => setState(() => _filter = 'Absent')),
                  _FilterChip('Late', _filter == 'Late',
                      () => setState(() => _filter = 'Late')),
                ],
              ),
            ),
            Expanded(
              child: attendanceAsync.when(
                data: (records) {
                  final filtered = _filter == 'All'
                      ? records
                      : records
                          .where((r) =>
                              r.status.name.toLowerCase() ==
                              _filter.toLowerCase())
                          .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_available_outlined,
                               size: 80, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                          const SizedBox(height: 16),
                          Text('No attendance records',
                              style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _EnhancedAttendanceCard(record: filtered[index]),
                  );
                },
                loading: () => const AttendanceSkeleton(),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMarkDialog(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final studentIdCtl = TextEditingController();
    final classIdCtl = TextEditingController();
    AttendanceStatus status = AttendanceStatus.present;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle, color: Colors.black87),
            ),
            const SizedBox(width: 12),
            const Text('Mark Attendance'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: studentIdCtl,
                decoration: InputDecoration(
                  labelText: 'Student ID',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: classIdCtl,
                decoration: InputDecoration(
                  labelText: 'Class ID',
                  prefixIcon: const Icon(Icons.class_),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AttendanceStatus>(
                initialValue: status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  prefixIcon: const Icon(Icons.event_available),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: AttendanceStatus.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) status = v;
                },
              ),
            ],
          ),
        ),
        actions: [
          ModernButton(
              label: 'Cancel',
              onPressed: () => Navigator.pop(context),
              isOutlined: true),
          ModernButton(
            label: 'Mark',
            icon: Icons.check,
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final now = DateTime.now();
              final attendance = Attendance(
                id: 'att_${now.millisecondsSinceEpoch}',
                studentId: studentIdCtl.text,
                classId: classIdCtl.text,
                date: now,
                status: status,
                createdAt: now,
              );
              ref
                  .read(attendanceNotifierProvider.notifier)
                  .addAttendance(attendance);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip(this.label, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.12),
      selectedColor:
          theme.colorScheme.primary.withValues(alpha: 0.2),
    );
  }
}

class _EnhancedAttendanceCard extends StatelessWidget {
  final Attendance record;

  const _EnhancedAttendanceCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = record.status == AttendanceStatus.present
        ? Colors.black87
        : record.status == AttendanceStatus.late
            ? Colors.orange
            : record.status == AttendanceStatus.leave
                ? Colors.black87
                : Colors.red;

    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                record.status == AttendanceStatus.present
                    ? Icons.check
                    : record.status == AttendanceStatus.late
                        ? Icons.schedule
                        : record.status == AttendanceStatus.leave
                            ? Icons.event_busy
                            : Icons.close,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student: ${record.studentId}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${record.date.day}/${record.date.month}/${record.date.year}',
                    style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            ModernBadge(label: record.status.name.toUpperCase(), color: color),
          ],
        ),
      ),
    );
  }
}
