import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:course_users/components/skeleton_widgets.dart';
import 'package:course_users/widgets/paginated_list_view.dart';

// ============================================
// PARENT PANEL SCREENS (all in one file)
// ============================================


// ============================================
// PARENT PANEL SCREENS
// ============================================

/// 1. My Children Profile Screen
class ChildrenProfileScreen extends ConsumerWidget {
  const ChildrenProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Children'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: supabase
            .from('parent_students')
            .select('*, students(*)')
            .eq('parent_id', userId ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final children = snapshot.data as List? ?? [];

          if (children.isEmpty) {
            final theme = Theme.of(context);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.family_restroom, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  SizedBox(height: 16),
                  Text('No children linked',
                      style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child =
                  children[index]['students'] as Map<String, dynamic>?;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: Text(
                      (child?['full_name']?[0] ?? 'C').toUpperCase(),
                      style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(child?['full_name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Class: ${child?['class_id'] ?? 'N/A'}'),
                      Text('ID: ${child?['student_code'] ?? 'N/A'}'),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChildDetailScreen(childData: child),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: (100 * index).ms, duration: 400.ms);
            },
          );
        },
      ),
    );
  }
}

/// 2. Child Detail Screen
class ChildDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? childData;
  const ChildDetailScreen({super.key, required this.childData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(childData?['full_name'] ?? 'Child Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    child: Text(
                      (childData?['full_name']?[0] ?? 'C').toUpperCase(),
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(childData?['full_name'] ?? 'Unknown',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(childData?['student_code'] ?? '',
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Information Cards
            _InfoCard(title: 'Academic Info', children: [
              _InfoRow('Class', childData?['class_id']?.toString() ?? 'N/A'),
              _InfoRow(
                  'Program', childData?['program_id']?.toString() ?? 'N/A'),
              _InfoRow('Enrollment Date',
                  _formatDate(childData?['enrollment_date'])),
              _InfoRow('Status',
                  childData?['status']?.toString().toUpperCase() ?? 'ACTIVE'),
            ]),
            const SizedBox(height: 16),
            _InfoCard(title: 'Performance', children: [
              _InfoRow(
                  'Attendance', '${childData?['attendance_percentage'] ?? 0}%'),
              _InfoRow('Average Grade', '${childData?['average_grade'] ?? 0}%'),
              _InfoRow('Outstanding Fees',
                  '\$${childData?['outstanding_balance'] ?? 0}'),
            ]),
            const SizedBox(height: 16),
            _InfoCard(title: 'Guardian Info', children: [
              _InfoRow('Guardian', childData?['guardian_name'] ?? 'N/A'),
              _InfoRow('Phone', childData?['guardian_phone'] ?? 'N/A'),
              _InfoRow('Email', childData?['guardian_email'] ?? 'N/A'),
            ]),
            const SizedBox(height: 24),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.grade),
                    label: const Text('View Grades'),
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Attendance'),
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
    } catch (e) {
      return 'Invalid';
    }
  }
}

/// 3. Fee Payment History Screen
class FeePaymentHistoryScreen extends ConsumerWidget {
  const FeePaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: supabase
            .from('payments')
            .select('*')
            .order('payment_date', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final payments = snapshot.data as List? ?? [];

          if (payments.isEmpty) {
            return const Center(child: Text('No payment history'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(Icons.receipt_long, color: Colors.grey.shade800),
                  ),
                  title: Text(payment['payment_number'] ?? 'Payment'),
                  subtitle: Text(_formatDate(payment['payment_date'])),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                          '\$${(payment['amount'] as num? ?? 0).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(payment['status'] ?? 'Completed',
                          style: TextStyle(
                              fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
    } catch (e) {
      return 'Invalid';
    }
  }
}

/// 4. Parent-Teacher Meetings Screen
class ParentTeacherMeetingsScreen extends ConsumerWidget {
  const ParentTeacherMeetingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent-Teacher Meetings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: supabase
            .from('events')
            .select('*')
            .eq('event_type', 'meeting')
            .order('start_date', ascending: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final meetings = snapshot.data as List? ?? [];

          final theme = Theme.of(context);
          if (meetings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.groups, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('No meetings scheduled',
                      style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: meetings.length,
            itemBuilder: (context, index) {
              final meeting = meetings[index];
              final isUpcoming =
                  DateTime.tryParse(meeting['start_date']?.toString() ?? '')
                          ?.isAfter(DateTime.now()) ??
                      false;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUpcoming
                              ? Colors.grey.shade300
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.groups,
                            color: isUpcoming ? Colors.black87 : Colors.black87,
                            size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(meeting['title'] ?? 'Meeting',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(meeting['location'] ?? 'Online',
                                style: TextStyle(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(_formatDateTime(meeting['start_date']),
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      if (isUpcoming)
                        FilledButton(
                          onPressed: () {},
                          child: const Text('Join'),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _formatDateTime(dynamic date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.parse(date));
    } catch (e) {
      return 'Invalid';
    }
  }
}

/// 5. School Calendar Screen
class SchoolCalendarScreen extends ConsumerWidget {
  const SchoolCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('School Calendar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: supabase
            .from('events')
            .select('*')
            .order('start_date', ascending: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final events = snapshot.data as List? ?? [];

          if (events.isEmpty) {
            final theme = Theme.of(context);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('No upcoming events',
                      style: TextStyle(
                          fontSize: 18,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6))),
                ],
              ),
            );
          }

          // Group events by month for the calendar view
          final grouped = <String, List<Map<String, dynamic>>>{};
          for (final ev in events) {
            final date = DateTime.tryParse(ev['start_date']?.toString() ?? '');
            final key = date == null
                ? 'Upcoming'
                : DateFormat('MMMM yyyy').format(date);
            grouped.putIfAbsent(key, () => []).add(ev);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Academic Year',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...grouped.entries.map((entry) {
                return _CalendarMonth(
                  month: entry.key,
                  events: entry.value
                      .map((ev) => _CalendarEvent(
                            ev['title']?.toString() ?? 'Event',
                            _formatEventDate(ev['start_date']),
                            _eventColor(ev['event_type']),
                          ))
                      .toList(),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  static String _formatEventDate(dynamic date) {
    if (date == null) return 'TBD';
    try {
      return DateFormat('MMM d').format(DateTime.parse(date));
    } catch (e) {
      return 'TBD';
    }
  }

  static Color _eventColor(dynamic type) {
    switch (type?.toString().toLowerCase()) {
      case 'holiday':
        return Colors.red;
      case 'exam':
        return Colors.orange;
      case 'meeting':
        return Colors.black87;
      case 'sports':
        return Colors.black87;
      case 'activity':
        return Colors.purple;
      default:
        return Colors.black87;
    }
  }
}

/// 6. Transport Tracking Screen
class TransportTrackingScreen extends ConsumerWidget {
  const TransportTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Tracking'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: Future.wait([
          supabase.from('vehicles').select('*').order('created_at'),
          supabase.from('users').select('id, full_name, phone'),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final results = snapshot.data as List? ?? [];
          final vehicles = (results.isNotEmpty ? results[0] : []) as List;
          final profiles = (results.length > 1 ? results[1] : []) as List;

          final vehicle =
              vehicles.isNotEmpty ? vehicles.first as Map : null;
          final profileMap = {
            for (final p in profiles) p['id']?.toString(): p,
          };
          final driver = vehicle?['driver_id'] != null
              ? profileMap[vehicle!['driver_id'].toString()]
              : null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Current Trip
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.grey.shade700, Colors.grey.shade900]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_bus,
                            color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                vehicle?['plate_number']?.toString() ??
                                    'Bus #1',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                '${vehicle?['model'] ?? 'School Bus'} • ${vehicle?['vehicle_type'] ?? 'bus'}',
                                style: const TextStyle(
                                    color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _TripInfo(
                              icon: Icons.directions_bus,
                              label: 'Vehicle Type',
                              value: vehicle?['vehicle_type']?.toString() ??
                                  'Bus'),
                          _TripInfo(
                              icon: Icons.event_seat,
                              label: 'Capacity',
                              value: vehicle?['capacity']?.toString() ?? '—'),
                          _TripInfo(
                              icon: Icons.access_time,
                              label: 'Status',
                              value: vehicle?['status']?.toString() ??
                                  'Active'),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms),
              const SizedBox(height: 24),

              // Fleet Info
              const Text('School Fleet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (vehicles.isEmpty)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No vehicles available'),
                ))
              else
                ...vehicles.map((v) {
                  final isActive = v['status'] == 'active';
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.directions_bus,
                          color: isActive ? Colors.black87 : Colors.orange),
                      title:
                          Text(v['plate_number']?.toString() ?? 'Vehicle'),
                      subtitle: Text(
                          '${v['model'] ?? 'Bus'} • Capacity: ${v['capacity'] ?? '—'}'),
                      trailing: isActive
                          ? const Chip(
                              label: Text('Active'),
                              backgroundColor: Colors.black87)
                          : Chip(
                              label: Text(
                                  v['status']?.toString() ?? 'Scheduled')),
                    ),
                  );
                }),
              const SizedBox(height: 24),

              // Driver Info
              const Text('Driver Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (driver == null)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No driver assigned'),
                ))
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                            radius: 30, child: Icon(Icons.person, size: 32)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(driver?['full_name']?.toString() ??
                                  'Driver',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text('Assigned to vehicle ${vehicle?['plate_number'] ?? ''}',
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6))),
                              Text('Phone: ${driver?['phone'] ?? 'N/A'}',
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6))),
                            ],
                          ),
                        ),
                        IconButton(
                            icon: const Icon(Icons.call, color: Colors.black87),
                            onPressed: () {}),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// 7. Health Records Screen
class HealthRecordsScreen extends ConsumerWidget {
  const HealthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: supabase
            .from('student_documents')
            .select('*, students(full_name)')
            .eq('document_type', 'health'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final records = snapshot.data as List? ?? [];

          if (records.isEmpty) {
            final theme = Theme.of(context);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_information,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('No health records',
                      style: TextStyle(
                          fontSize: 18,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6))),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HealthCard(
                title: 'Health Documents',
                icon: Icons.medical_information,
                color: Colors.black87,
                items: records
                    .map((r) =>
                        '${r['title'] ?? 'Record'} — ${_formatDate(r['issue_date'])}')
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
    } catch (e) {
      return 'Invalid';
    }
  }
}

/// 8. Leave Applications Screen (Parent)
class ParentLeaveApplicationsScreen extends ConsumerStatefulWidget {
  const ParentLeaveApplicationsScreen({super.key});

  @override
  ConsumerState<ParentLeaveApplicationsScreen> createState() =>
      _ParentLeaveScreenState();
}

class _ParentLeaveScreenState
    extends ConsumerState<ParentLeaveApplicationsScreen> {
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Applications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Apply Leave Form
            const Text('Apply for Leave',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Reason for Leave',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DatePickerField(
                    label: 'Start Date',
                    selectedDate: _startDate,
                    onDateSelected: (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerField(
                    label: 'End Date',
                    selectedDate: _endDate,
                    onDateSelected: (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _submitLeave(),
              icon: const Icon(Icons.send),
              label: const Text('Submit Application'),
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
            const SizedBox(height: 32),

            // Previous Applications
            const Text('Previous Applications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            FutureBuilder(
              future: _loadLeaveHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final history = snapshot.data as List? ?? [];
                if (history.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('No leave applications yet')),
                  );
                }
                return Column(
                  children: history
                      .map((item) => _LeaveHistoryTile(
                            status:
                                (item['status']?.toString() ?? 'pending')
                                    .toUpperCase(),
                            date: _formatHistoryDate(item['created_at']),
                            reason: item['reason']?.toString() ?? '',
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitLeave() async {
    if (_reasonController.text.trim().isEmpty ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields'),
            backgroundColor: Colors.black87),
      );
      return;
    }
    try {
      final client = Supabase.instance.client;
      // Resolve the linked student for this parent (first child).
      final links = await client
          .from('parent_students')
          .select('student_id')
          .eq('parent_id', client.auth.currentUser?.id ?? '')
          .limit(1);
      final studentId =
          (links.isNotEmpty ? links.first['student_id'] : null) as String?;
      if (studentId == null) {
        throw Exception('No linked student found');
      }
      await client.from('student_leaves').insert({
        'student_id': studentId,
        'start_date': _startDate!.toIso8601String(),
        'end_date': _endDate!.toIso8601String(),
        'reason': _reasonController.text.trim(),
        'status': 'pending',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Leave application submitted'),
              backgroundColor: Colors.black87),
        );
        _reasonController.clear();
        setState(() {
          _startDate = null;
          _endDate = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _loadLeaveHistory() async {
    try {
      final client = Supabase.instance.client;
      final links = await client
          .from('parent_students')
          .select('student_id')
          .eq('parent_id', client.auth.currentUser?.id ?? '')
          .limit(1);
      final studentId =
          (links.isNotEmpty ? links.first['student_id'] : null) as String?;
      if (studentId == null) return [];
      final data = await client
          .from('student_leaves')
          .select('*')
          .eq('student_id', studentId)
          .order('created_at', ascending: false)
          .limit(20);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  String _formatHistoryDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
    } catch (e) {
      return 'N/A';
    }
  }
}

/// 9. Complaints & Feedback Screen
class ParentComplaintsScreen extends ConsumerStatefulWidget {
  const ParentComplaintsScreen({super.key});

  @override
  ConsumerState<ParentComplaintsScreen> createState() =>
      _ParentComplaintsScreenState();
}

class _ParentComplaintsScreenState
    extends ConsumerState<ParentComplaintsScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'general';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints & Feedback'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Submit Feedback',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(
                labelText: 'Category',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'academic', child: Text('Academic')),
                DropdownMenuItem(
                    value: 'infrastructure', child: Text('Infrastructure')),
                DropdownMenuItem(value: 'staff', child: Text('Staff')),
                DropdownMenuItem(value: 'general', child: Text('General')),
              ],
              onChanged: (v) => setState(() => _category = v ?? 'general'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Description',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _submitComplaint(),
              icon: const Icon(Icons.send),
              label: const Text('Submit'),
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComplaint() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields'),
            backgroundColor: Colors.black87),
      );
      return;
    }
    try {
      await Supabase.instance.client.from('support_tickets').insert({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _category,
        'priority': 'normal',
        'status': 'open',
        'reported_by': Supabase.instance.client.auth.currentUser?.id,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Feedback submitted'),
              backgroundColor: Colors.black87),
        );
        _titleController.clear();
        _descriptionController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    }
  }
}

/// 10. Notice Board Detail Screen
class NoticeBoardScreen extends ConsumerWidget {
  const NoticeBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Board'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: supabase
            .from('announcements')
            .select('*')
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final notices = snapshot.data as List? ?? [];

          if (notices.isEmpty) {
            return const Center(child: Text('No notices available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(context, notice['priority']),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.campaign, color: Colors.white),
                  ),
                  title: Text(notice['title'] ?? 'Notice',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(notice['audience']?.toString() ?? 'All'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notice['content'] ?? '',
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          Text('Posted: ${_formatDate(notice['created_at'])}',
                              style: TextStyle(
                                  fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getPriorityColor(BuildContext context, String? priority) {
    final theme = Theme.of(context);
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
        return Colors.black87;
      default:
        return theme.colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  static String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
    } catch (e) {
      return 'Invalid';
    }
  }
}

// Helper Widgets
class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TripInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _TripInfo(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _CalendarMonth extends StatelessWidget {
  final String month;
  final List<_CalendarEvent> events;
  const _CalendarMonth({required this.month, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(month,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...events.map((e) => _CalendarEventTile(event: e)),
      ],
    );
  }
}

class _CalendarEvent {
  final String title;
  final String date;
  final Color color;
  _CalendarEvent(this.title, this.date, this.color);
}

class _CalendarEventTile extends StatelessWidget {
  final _CalendarEvent event;
  const _CalendarEventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: event.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: event.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                  color: event.color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(event.date,
                    style:
                        TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;
  const _HealthCard(
      {required this.title,
      required this.icon,
      required this.color,
      required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: color),
                      const SizedBox(width: 8),
                      Text(item),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _LeaveHistoryTile extends StatelessWidget {
  final String status;
  final String date;
  final String reason;
  const _LeaveHistoryTile(
      {required this.status, required this.date, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          status == 'Approved'
              ? Icons.check_circle
              : status == 'Rejected'
                  ? Icons.cancel
                  : Icons.pending,
          color: status == 'Approved'
              ? Colors.black87
              : status == 'Rejected'
                  ? Colors.red
                  : Colors.orange,
        ),
        title: Text(reason),
        subtitle: Text(date),
        trailing: Chip(
          label: Text(status),
          backgroundColor: status == 'Approved'
              ? Colors.black.withValues(alpha: 0.2)
              : status == 'Rejected'
                  ? Colors.red.withValues(alpha: 0.2)
                  : Colors.orange.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  const _DatePickerField(
      {required this.label,
      required this.selectedDate,
      required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) onDateSelected(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(selectedDate != null
            ? DateFormat('MMM dd, yyyy').format(selectedDate!)
            : 'Select date'),
      ),
    );
  }
}


// ============================================
// MORE PARENT PANEL SCREENS
// ============================================

/// 11. Parent Profile Screen
class ParentProfileScreen extends ConsumerStatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  ConsumerState<ParentProfileScreen> createState() =>
      _ParentProfileScreenState();
}

class _ParentProfileScreenState extends ConsumerState<ParentProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final data = await Supabase.instance.client
          .from('users')
          .select('*')
          .eq('id', userId ?? '')
          .limit(1);
      if (!mounted) return;
      final list = data as List? ?? [];
      if (list.isNotEmpty) {
        final p = list.first as Map;
        _nameController.text = p['full_name']?.toString() ?? '';
        _phoneController.text = p['phone']?.toString() ?? '';
        _addressController.text = p['address']?.toString() ?? '';
      }
      setState(() => _loaded = true);
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  Future<void> _saveProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final client = Supabase.instance.client;
      final data = {
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      };
      final res = await client
          .from('users')
          .update(data)
          .eq('id', userId ?? '')
          .select();
      if ((res as List).isEmpty && userId != null) {
        await client.from('users').insert({
          ...data,
          'id': userId,
          'role': 'guardian',
          'email':
              client.auth.currentUser?.email ?? '$userId@emis.local',
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile updated'),
              backgroundColor: Colors.black87),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: !_loaded
          ? const SkeletonDashboard()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    child:
                        const Icon(Icons.person, size: 60, color: Colors.black87),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black87, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                prefixIcon: const Icon(Icons.phone),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Address',
                prefixIcon: const Icon(Icons.location_on),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 12. Emergency Contacts Screen
class EmergencyContactsScreen extends ConsumerWidget {
  const EmergencyContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: supabase
            .from('users')
            .select('id, full_name, role, phone, email')
            .inFilter('role',
                ['admin', 'receptionist', 'teacher', 'accountant'])
            .order('full_name')
            .limit(30),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final contacts = snapshot.data as List? ?? [];

          if (contacts.isEmpty) {
            final theme = Theme.of(context);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.contacts,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('No contacts available',
                      style: TextStyle(
                          fontSize: 18,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6))),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: contacts
                .map((c) => _EmergencyContactTile(
                      name: c['full_name']?.toString() ?? 'Contact',
                      role: c['role']?.toString() ?? '',
                      phone: c['phone']?.toString() ??
                          c['email']?.toString() ??
                          '',
                      icon: Icons.contact_page,
                      color: Colors.black87,
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

/// 13. Children Attendance Detail Screen
class ChildrenAttendanceScreen extends ConsumerWidget {
  const ChildrenAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Report'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: () async {
          // Resolve this parent's child, then load their attendance.
          final userId = supabase.auth.currentUser?.id;
          final links = await supabase
              .from('parent_students')
              .select('student_id')
              .eq('parent_id', userId ?? '')
              .limit(1);
          final studentId =
              (links.isNotEmpty ? links.first['student_id'] : null)
                  as String?;
          if (studentId == null) return <Map<String, dynamic>>[];
          final data = await supabase
              .from('attendance')
              .select('*')
              .eq('person_id', studentId)
              .eq('person_type', 'student')
              .order('date', ascending: false)
              .limit(30);
          return (data as List).cast<Map<String, dynamic>>();
        }(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final attendance = snapshot.data as List? ?? [];

          // Calculate stats
          final present =
              attendance.where((a) => a['status'] == 'present').length;
          final absent =
              attendance.where((a) => a['status'] == 'absent').length;
          final late = attendance.where((a) => a['status'] == 'late').length;
          final percentage =
              attendance.isEmpty ? 0 : (present / attendance.length * 100);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary
                Row(
                  children: [
                    _AttendanceStatCard(
                        label: 'Present',
                        value: present.toString(),
                        color: Colors.black87,
                        icon: Icons.check_circle),
                    const SizedBox(width: 12),
                    _AttendanceStatCard(
                        label: 'Absent',
                        value: absent.toString(),
                        color: Colors.red,
                        icon: Icons.cancel),
                    const SizedBox(width: 12),
                    _AttendanceStatCard(
                        label: 'Late',
                        value: late.toString(),
                        color: Colors.orange,
                        icon: Icons.access_time),
                  ],
                ).animate().fadeIn(duration: 600.ms),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pie_chart, color: Colors.black87),
                      const SizedBox(width: 8),
                      Text(
                          'Overall Attendance: ${percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Daily Records',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...attendance.take(15).map((record) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          record['status'] == 'present'
                              ? Icons.check_circle
                              : record['status'] == 'absent'
                                  ? Icons.cancel
                                  : Icons.access_time,
                          color: record['status'] == 'present'
                              ? Colors.black87
                              : record['status'] == 'absent'
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                        title: Text(_formatDate(record['date'])),
                        subtitle: Text(
                            'Status: ${record['status']?.toString().toUpperCase() ?? 'Unknown'}'),
                        trailing: record['remarks'] != null
                            ? Text(record['remarks'],
                                style: const TextStyle(fontSize: 11))
                            : null,
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
    } catch (e) {
      return 'Invalid';
    }
  }
}

/// 14. Report Cards Download Screen
class ReportCardsScreen extends ConsumerWidget {
  const ReportCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Cards'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: supabase
            .from('grades')
            .select('*, students(full_name), exams(name)')
            .order('created_at', ascending: false)
            .limit(30),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final grades = snapshot.data as List? ?? [];

          if (grades.isEmpty) {
            final theme = Theme.of(context);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('No report cards yet',
                      style: TextStyle(
                          fontSize: 18,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6))),
                ],
              ),
            );
          }

          // Group by student for one report card per student
          final byStudent = <String, List<Map<String, dynamic>>>{};
          for (final g in grades) {
            final student = (g['students'] as Map<String, dynamic>?)?['full_name']
                    ?.toString() ??
                'Student';
            byStudent.putIfAbsent(student, () => []).add(g);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: byStudent.entries.map((entry) {
              final avg = entry.value.fold<double>(
                      0,
                      (sum, g) =>
                          sum + (double.tryParse(g['grade']?.toString() ?? '0') ??
                              0)) /
                  (entry.value.isEmpty ? 1 : entry.value.length);
              final letter = _letterGrade(avg);
              return _ReportCardTile(
                title: entry.key,
                date: _formatDate(entry.value.first['created_at']),
                grade: letter,
                percentage: avg,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  static String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
    } catch (e) {
      return 'N/A';
    }
  }

  static String _letterGrade(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'A-';
    if (score >= 75) return 'B+';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    return 'D';
  }
}

/// 15. Co-curricular Activities Screen
class CoCurricularActivitiesScreen extends ConsumerWidget {
  const CoCurricularActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Co-curricular Activities'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: supabase.from('student_groups').select('*'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final groups = snapshot.data as List? ?? [];

          if (groups.isEmpty) {
            final theme = Theme.of(context);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.groups,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('No activities available',
                      style: TextStyle(
                          fontSize: 18,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6))),
                ],
              ),
            );
          }

          return GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: groups
                .map((g) => _ActivityCard(
                      title: g['name']?.toString() ?? 'Activity',
                      icon: Icons.groups,
                      color: Colors.black87,
                      members: 0,
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

/// 16. Parent Settings Screen
class ParentSettingsScreen extends StatelessWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Notifications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Attendance Alerts'),
            subtitle: const Text('Get notified about attendance'),
            value: true,
            onChanged: (v) {},
          ),
          SwitchListTile(
            title: const Text('Grade Updates'),
            subtitle: const Text('Receive grade notifications'),
            value: true,
            onChanged: (v) {},
          ),
          SwitchListTile(
            title: const Text('Fee Reminders'),
            subtitle: const Text('Payment due reminders'),
            value: true,
            onChanged: (v) {},
          ),
          SwitchListTile(
            title: const Text('School Announcements'),
            subtitle: const Text('General school updates'),
            value: false,
            onChanged: (v) {},
          ),
          const Divider(height: 32),
          const Text('Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.black87),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.devices, color: Colors.purple),
            title: const Text('Logged-in Devices'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.orange),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.black87),
            title: const Text('About'),
            subtitle: const Text('Version 1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// 17. Events Registration Screen
class EventsRegistrationScreen extends ConsumerWidget {
  const EventsRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('School Events'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: supabase
            .from('events')
            .select('*')
            .order('start_date', ascending: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final events = snapshot.data as List? ?? [];

          if (events.isEmpty) {
            return const Center(child: Text('No upcoming events'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Colors.purple.shade400,
                                Colors.purple.shade700
                              ]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.event,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(event['title'] ?? 'Event',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text(_formatDate(event['start_date']),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(event['description'] ?? 'No description',
                          style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Chip(
                            avatar: const Icon(Icons.location_on, size: 16),
                            label: Text(event['location'] ?? 'TBD'),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: () {},
                            child: const Text('Register'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.parse(date));
    } catch (e) {
      return 'Invalid';
    }
  }
}

// Helper Widgets
class _EmergencyContactTile extends StatelessWidget {
  final String name;
  final String role;
  final String phone;
  final IconData icon;
  final Color color;

  const _EmergencyContactTile({
    required this.name,
    required this.role,
    required this.phone,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(role),
        trailing: IconButton(
          icon: const Icon(Icons.call, color: Colors.black87),
          onPressed: () {},
        ),
      ),
    );
  }
}

class _AttendanceStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _AttendanceStatCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }
}

class _ReportCardTile extends StatelessWidget {
  final String title;
  final String date;
  final String grade;
  final double percentage;

  const _ReportCardTile(
      {required this.title,
      required this.date,
      required this.grade,
      required this.percentage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.grey.shade600, Colors.grey.shade800]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(date,
                        style: TextStyle(
                            fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Chip(
                            label: Text('Grade: $grade'),
                            backgroundColor: Colors.black.withValues(alpha: 0.2)),
                        const SizedBox(width: 8),
                        Text('${percentage.toStringAsFixed(1)}%',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.download, color: Colors.black87),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int members;

  const _ActivityCard(
      {required this.title,
      required this.icon,
      required this.color,
      required this.members});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 12),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text('$members members',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}


// ============================================
// PARENT PANEL SCREENS - PART 3
// ============================================

/// 1. Parent Messaging / Communication Hub
class ParentMessagingScreen extends ConsumerStatefulWidget {
  const ParentMessagingScreen({super.key});

  @override
  ConsumerState<ParentMessagingScreen> createState() =>
      _ParentMessagingScreenState();
}

class _ParentMessagingScreenState extends ConsumerState<ParentMessagingScreen> {
  final _messageController = TextEditingController();
  String _selectedRecipient = 'class_teacher';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Contacts
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _QuickContact(
                  name: 'Class Teacher',
                  icon: Icons.person,
                  color: Colors.black87,
                  isSelected: _selectedRecipient == 'class_teacher',
                  onTap: () =>
                      setState(() => _selectedRecipient = 'class_teacher'),
                ),
                _QuickContact(
                  name: 'Principal',
                  icon: Icons.school,
                  color: Colors.purple,
                  isSelected: _selectedRecipient == 'principal',
                  onTap: () => setState(() => _selectedRecipient = 'principal'),
                ),
                _QuickContact(
                  name: 'Admin',
                  icon: Icons.admin_panel_settings,
                  color: Colors.black87,
                  isSelected: _selectedRecipient == 'admin',
                  onTap: () => setState(() => _selectedRecipient = 'admin'),
                ),
                _QuickContact(
                  name: 'Transport',
                  icon: Icons.directions_bus,
                  color: Colors.orange,
                  isSelected: _selectedRecipient == 'transport',
                  onTap: () => setState(() => _selectedRecipient = 'transport'),
                ),
                _QuickContact(
                  name: 'Accounts',
                  icon: Icons.account_balance,
                  color: Colors.black87,
                  isSelected: _selectedRecipient == 'accounts',
                  onTap: () => setState(() => _selectedRecipient = 'accounts'),
                ),
              ],
            ),
          ),
          const Divider(),

          // Messages List
          Expanded(
            child: PaginatedListView<Map<String, dynamic>>(
              fetcher: (page, pageSize) async {
                final data = await supabase
                    .from('parent_messages')
                    .select('*')
                    .eq('parent_id', userId ?? '')
                    .order('created_at', ascending: false)
                    .range(page * pageSize, page * pageSize + pageSize - 1);
                return List<Map<String, dynamic>>.from(data);
              },
              skeleton: (context) => const SkeletonListPage(itemCount: 8),
              empty: (context, _) {
                final theme = Theme.of(context);
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.forum_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text('No messages yet',
                          style: TextStyle(
                              fontSize: 18,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6))),
                      const SizedBox(height: 8),
                      Text('Start a conversation with teachers or admin',
                          style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6))),
                    ],
                  ),
                );
              },
              itemBuilder: (context, msg, index) {
                final theme = Theme.of(context);
                final isRead = msg['read'] ?? false;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isRead ? null : Colors.grey.shade200,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      child: Icon(Icons.message,
                          color: Colors.grey.shade800, size: 20),
                    ),
                    title: Text(msg['subject'] ?? 'No Subject',
                        style: TextStyle(
                            fontWeight: isRead
                                ? FontWeight.normal
                                : FontWeight.bold)),
                    subtitle: Text(msg['message'] ?? '',
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(
                      _formatTime(msg['created_at']),
                      style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6)),
                    ),
                    onTap: () {},
                  ),
                )
                    .animate()
                    .fadeIn(delay: (50 * index).ms, duration: 300.ms);
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () async {
                    if (_messageController.text.isNotEmpty) {
                      try {
                        await Supabase.instance.client
                            .from('parent_messages')
                            .insert({
                          'parent_id': Supabase.instance.client.auth
                              .currentUser?.id,
                          'subject': _selectedRecipient,
                          'message': _messageController.text.trim(),
                          'read': false,
                        });
                        _messageController.clear();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Message sent!')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic date) {
    if (date == null) return '';
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(date));
    } catch (e) {
      return '';
    }
  }
}

/// 2. Performance Tracking Screen
class PerformanceTrackingScreen extends ConsumerWidget {
  const PerformanceTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Tracking'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: userId != null
            ? supabase
                .from('parent_students')
                .select('*, students(*)')
                .eq('parent_id', userId)
            : Future.value([]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final rows = (snapshot.data ?? [])
              .map((r) => r['students'])
              .whereType<Map<String, dynamic>>()
              .toList();

          if (rows.isEmpty) {
            return const Center(child: Text('No children enrolled'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final theme = Theme.of(context);
              final child = rows[index];
              final name = child['full_name']?.toString() ?? 'Unknown';
              final cls = child['class_id']?.toString() ?? 'No class';
              final avgGrade = double.tryParse(
                      child['average_grade']?.toString() ?? '0') ??
                  0;
              final attendance = double.tryParse(
                      child['attendance_percentage']?.toString() ?? '0') ??
                  0;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            child: Text(
                              (name.isNotEmpty ? name[0] : '?'),
                              style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text(cls,
                                    style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 16),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _PerformanceMetric(
                            label: 'Avg Grade',
                            value: '${avgGrade.toStringAsFixed(0)}%',
                            color: avgGrade >= 80
                                ? Colors.black87
                                : avgGrade >= 60
                                    ? Colors.orange
                                    : Colors.red,
                            icon: Icons.grade,
                          ),
                          const SizedBox(width: 12),
                          _PerformanceMetric(
                            label: 'Attendance',
                            value: '${attendance.toStringAsFixed(0)}%',
                            color: attendance >= 90
                                ? Colors.black87
                                : attendance >= 75
                                    ? Colors.orange
                                    : Colors.red,
                            icon: Icons.check_circle,
                          ),
                          const SizedBox(width: 12),
                          _PerformanceMetric(
                            label: 'Rank',
                            value: '#${(index + 1) * 5}',
                            color: Colors.black87,
                            icon: Icons.leaderboard,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: avgGrade / 100,
                          backgroundColor: theme.colorScheme.onSurface
                              .withValues(alpha: 0.2),
                          color: Colors.black87,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (100 * index).ms, duration: 400.ms);
            },
          );
        },
      ),
    );
  }
}

/// 3. Parent Volunteer Screen
class ParentVolunteerScreen extends ConsumerStatefulWidget {
  const ParentVolunteerScreen({super.key});

  @override
  ConsumerState<ParentVolunteerScreen> createState() =>
      _ParentVolunteerScreenState();
}

class _ParentVolunteerScreenState extends ConsumerState<ParentVolunteerScreen> {
  List<_VolunteerItem> _opportunities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOpportunities();
  }

  Future<void> _loadOpportunities() async {
    try {
      // Volunteer opportunities are published as public events.
      final data = await Supabase.instance.client
          .from('events')
          .select('*')
          .eq('is_public', true)
          .order('start_date')
          .limit(30);
      if (!mounted) return;
      setState(() {
        _opportunities = (data as List)
            .map((item) => _VolunteerItem(
                  title: item['title'] ?? '',
                  description: item['description'] ?? '',
                  date: item['start_date']?.toString() ?? '',
                  spots: item['max_participants'] ?? 0,
                  icon: _mapVolunteerIcon(item['event_type']),
                  color: _mapColor(item['event_type']),
                ))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Volunteer Opportunities'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const SkeletonDashboard(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Opportunities'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _opportunities.length,
        itemBuilder: (context, index) {
          final item = _opportunities[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, color: item.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(item.date,
                                style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text('${item.spots} spots'),
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(
                            color: Colors.grey.shade800, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(item.description,
                      style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7))),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Learn More'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Signed up for ${item.title}!')),
                          );
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (80 * index).ms, duration: 400.ms);
        },
      ),
    );
  }
}

/// 4. Parent Documents Screen
class ParentDocumentsScreen extends ConsumerStatefulWidget {
  const ParentDocumentsScreen({super.key});

  @override
  ConsumerState<ParentDocumentsScreen> createState() =>
      _ParentDocumentsScreenState();
}

class _ParentDocumentsScreenState extends ConsumerState<ParentDocumentsScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocumentCategories();
  }

  Future<void> _loadDocumentCategories() async {
    try {
      // Derive document categories from published announcements
      // that carry file attachments.
      final data = await Supabase.instance.client
          .from('announcements')
          .select('id, type, title, attachment_url, publish_date')
          .not('attachment_url', 'is', null)
          .order('publish_date', ascending: false)
          .limit(100);
      final docs = (data as List).cast<Map<String, dynamic>>();
      final byType = <String, List<Map<String, dynamic>>>{};
      for (final d in docs) {
        final t = (d['type']?.toString().isEmpty ?? true)
            ? 'document'
            : d['type'].toString();
        byType.putIfAbsent(t, () => []).add(d);
      }
      final categories = <Map<String, dynamic>>[];
      byType.forEach((type, items) {
        categories.add({
          'name': type[0].toUpperCase() + type.substring(1),
          'count': items.length,
          'icon': type,
          'color_name': type,
        });
      });
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const SkeletonDashboard()
          : FutureBuilder(
              future: supabase
                  .from('announcements')
                  .select('*')
                  .not('attachment_url', 'is', null)
                  .order('publish_date', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SkeletonDashboard();
                }
                final docs = snapshot.data as List? ?? [];

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('Document Categories',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: _categories.map((cat) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_mapDocumentIcon(cat['icon']),
                                    color: _mapColor(cat['color_name']),
                                    size: 32),
                                const SizedBox(height: 8),
                                Text(cat['name'] ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                    textAlign: TextAlign.center),
                                Text('${cat['count'] ?? 0} files',
                                    style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                        fontSize: 11)),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: 400.ms);
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text('Recent Documents',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (docs.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('No documents available',
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6))),
                        ),
                      )
                    else
                      ...docs.map((doc) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(Icons.insert_drive_file,
                                  color: Colors.grey.shade800),
                              title: Text(doc['title'] ?? 'Document'),
                              subtitle: Text(
                                  doc['publish_date']?.toString() ?? 'No date'),
                              trailing: const Icon(Icons.download),
                              onTap: () {},
                            ),
                          )),
                  ],
                );
              },
            ),
    );
  }
}

/// 5. School Gallery Screen
class SchoolGalleryScreen extends ConsumerStatefulWidget {
  const SchoolGalleryScreen({super.key});

  @override
  ConsumerState<SchoolGalleryScreen> createState() =>
      _SchoolGalleryScreenState();
}

class _SchoolGalleryScreenState extends ConsumerState<SchoolGalleryScreen> {
  List<Map<String, dynamic>> _albums = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    try {
      // Gallery albums are derived from the digital library media.
      final data = await Supabase.instance.client
          .from('digital_library')
          .select('*')
          .order('created_at', ascending: false)
          .limit(50);
      final items = (data as List).cast<Map<String, dynamic>>();
      final byType = <String, List<Map<String, dynamic>>>{};
      for (final item in items) {
        final t = (item['type']?.toString().isEmpty ?? true)
            ? 'image'
            : item['type'].toString();
        byType.putIfAbsent(t, () => []).add(item);
      }
      final albums = <Map<String, dynamic>>[];
      byType.forEach((type, list) {
        albums.add({
          'name': type[0].toUpperCase() + type.substring(1),
          'count': list.length,
          'icon': type,
          'color_name': type,
        });
      });
      if (!mounted) return;
      setState(() {
        _albums = albums;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('School Gallery'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const SkeletonDashboard(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('School Gallery'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Featured Image
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade600, Colors.grey.shade700],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library, color: Colors.white, size: 48),
                  SizedBox(height: 8),
                  Text('School Memories',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Text('Browse through our photo gallery',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 600.ms),
          const SizedBox(height: 24),

          const Text('Albums',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: _albums.map((album) {
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {},
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              _mapColor(album['color_name']).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_mapGalleryIcon(album['icon']),
                            color: _mapColor(album['color_name']), size: 36),
                      ),
                      const SizedBox(height: 8),
                      Text(album['name'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center),
                      Text('${album['count'] ?? 0} photos',
                          style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              fontSize: 11)),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// 6. Parent Alumni Network Screen
class ParentAlumniScreen extends ConsumerStatefulWidget {
  const ParentAlumniScreen({super.key});

  @override
  ConsumerState<ParentAlumniScreen> createState() => _ParentAlumniScreenState();
}

class _ParentAlumniScreenState extends ConsumerState<ParentAlumniScreen> {
  List<Map<String, dynamic>> _alumni = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlumni();
  }

  Future<void> _loadAlumni() async {
    try {
      // Alumni = students who have been issued completion certificates.
      final data = await Supabase.instance.client
          .from('certificates')
          .select('*, students(full_name)')
          .eq('status', 'issued')
          .order('issue_date', ascending: false)
          .limit(50);
      final certs = (data as List).cast<Map<String, dynamic>>();
      final alumni = <Map<String, dynamic>>[];
      for (final c in certs) {
        final student = c['students'] as Map? ?? {};
        alumni.add({
          'name': student['full_name'] ?? 'Graduate',
          'graduation_year':
              c['issue_date']?.toString().split('-').first ?? '',
          'achievement': c['course_name'] ?? c['certificate_type'] ?? '',
          'icon': c['certificate_type'],
          'color_name': c['certificate_type'],
        });
      }
      if (!mounted) return;
      setState(() {
        _alumni = alumni;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Alumni Network'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const SkeletonDashboard(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumni Network'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade600, Colors.grey.shade800],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.school, color: Colors.white, size: 36),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Our Alumni',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Text('500+ successful graduates',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms),
          const SizedBox(height: 24),
          const Text('Notable Alumni',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._alumni.map((a) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _mapColor(a['color_name']).withValues(alpha: 0.1),
                  child: Icon(_mapAlumniIcon(a['icon']),
                      color: _mapColor(a['color_name'])),
                ),
                title: Text(a['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a['graduation_year']?.toString() ?? '',
                        style: const TextStyle(fontSize: 12)),
                    Text(a['achievement'] ?? '',
                        style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6))),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.message, color: Colors.black87),
                  onPressed: () {},
                ),
              ),
            ).animate().fadeIn(duration: 400.ms);
          }),
        ],
      ),
    );
  }
}

/// 7. Parent Feedback Screen
class ParentFeedbackScreen extends ConsumerStatefulWidget {
  const ParentFeedbackScreen({super.key});

  @override
  ConsumerState<ParentFeedbackScreen> createState() =>
      _ParentFeedbackScreenState();
}

class _ParentFeedbackScreenState extends ConsumerState<ParentFeedbackScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _category = 'academic';
  int _rating = 4;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share Your Feedback',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Help us improve the school experience',
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 24),

            // Category
            const Text('Category',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['academic', 'facilities', 'transport', 'food', 'other']
                  .map((cat) => ChoiceChip(
                        label: Text(cat[0].toUpperCase() + cat.substring(1)),
                        selected: _category == cat,
                        onSelected: (_) => setState(() => _category = cat),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Rating
            const Text('Rating', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                return IconButton(
                  icon: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () => setState(() => _rating = i + 1),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Title
            const Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Brief title',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Body
            const Text('Details',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _bodyController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Tell us more...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: () async {
                try {
                  await Supabase.instance.client.from('feedback').insert({
                    'user_id': Supabase.instance.client.auth.currentUser?.id,
                    'title': _titleController.text.trim(),
                    'comment': _bodyController.text.trim(),
                    'rating': _rating,
                    'feedback_type': _category,
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Feedback submitted! Thank you.'),
                      ),
                    );
                    _titleController.clear();
                    _bodyController.clear();
                    setState(() => _rating = 0);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('Submit Feedback'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 0),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

// Helper widgets
class _QuickContact extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickContact({
    required this.name,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isSelected ? color : color.withValues(alpha: 0.2),
              child: Icon(icon,
                  color: isSelected ? Colors.white : color, size: 20),
            ),
            const SizedBox(height: 4),
            Text(name,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _PerformanceMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _PerformanceMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

IconData _mapVolunteerIcon(dynamic icon) {
  switch (icon?.toString().toLowerCase()) {
    case 'library_books':
    case 'library':
      return Icons.library_books;
    case 'sports_soccer':
    case 'sports':
    case 'sport':
      return Icons.sports_soccer;
    case 'directions_bus':
    case 'transport':
      return Icons.directions_bus;
    case 'science':
    case 'workshop':
      return Icons.science;
    case 'menu_book':
    case 'book':
      return Icons.menu_book;
    case 'volunteer_activism':
    case 'volunteer':
    case 'community':
    case 'charity':
    case 'fundraiser':
      return Icons.volunteer_activism;
    case 'music':
      return Icons.music_note;
    case 'celebration':
      return Icons.celebration;
    case 'nature':
    case 'environment':
      return Icons.nature;
    default:
      return Icons.volunteer_activism;
  }
}

IconData _mapDocumentIcon(dynamic icon) {
  switch (icon?.toString()) {
    case 'description':
      return Icons.description;
    case 'receipt_long':
      return Icons.receipt_long;
    case 'assessment':
      return Icons.assessment;
    case 'card_membership':
      return Icons.card_membership;
    case 'policy':
      return Icons.policy;
    case 'medical_services':
      return Icons.medical_services;
    default:
      return Icons.insert_drive_file;
  }
}

IconData _mapGalleryIcon(dynamic icon) {
  switch (icon?.toString()) {
    case 'sports':
      return Icons.sports;
    case 'science':
      return Icons.science;
    case 'music_note':
      return Icons.music_note;
    case 'celebration':
      return Icons.celebration;
    case 'nature':
      return Icons.nature;
    case 'school':
      return Icons.school;
    default:
      return Icons.photo_library;
  }
}

IconData _mapAlumniIcon(dynamic icon) {
  switch (icon?.toString()) {
    case 'computer':
      return Icons.computer;
    case 'medical_services':
      return Icons.medical_services;
    case 'architecture':
      return Icons.architecture;
    case 'business':
      return Icons.business;
    case 'rocket_launch':
      return Icons.rocket_launch;
    default:
      return Icons.person;
  }
}

Color _mapColor(dynamic colorName) {
  switch (colorName?.toString().toLowerCase()) {
    case 'blue':
    case 'workshop':
    case 'library':
      return Colors.black87;
    case 'green':
    case 'sports':
    case 'sport':
    case 'environment':
    case 'nature':
      return Colors.black87;
    case 'purple':
    case 'music':
      return Colors.purple;
    case 'orange':
    case 'volunteer':
    case 'community':
    case 'charity':
    case 'fundraiser':
      return Colors.orange;
    case 'red':
      return Colors.red;
    case 'pink':
      return Colors.pink;
    case 'brown':
      return Colors.brown;
    case 'teal':
    case 'indigo':
      return Colors.black87;
    case 'grey':
    case 'gray':
    case 'celebration':
      return Colors.grey;
    default:
      return Colors.grey;
  }
}

class _VolunteerItem {
  final String title;
  final String description;
  final String date;
  final int spots;
  final IconData icon;
  final Color color;

  _VolunteerItem({
    required this.title,
    required this.description,
    required this.date,
    required this.spots,
    required this.icon,
    required this.color,
  });
}
