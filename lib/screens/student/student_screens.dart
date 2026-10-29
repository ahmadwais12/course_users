import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:course_users/components/skeleton_widgets.dart';
import 'package:course_users/widgets/paginated_list_view.dart';
import 'package:course_users/models/attendance.dart';
import 'package:course_users/providers/student_providers.dart';
import 'package:course_users/widgets/adaptive/student_lifestyle_page.dart';
import 'package:course_users/widgets/adaptive/adaptive_widgets.dart';

// ============================================
// STUDENT PANEL SCREENS (all in one file)
// ============================================

// ============================================
// STUDENT PANEL SCREENS (all in one file)
// ============================================

/// 1. Course Detail Screen
class CourseDetailScreen extends ConsumerWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: supabase
            .from('courses')
            .select('*, teachers(*)')
            .eq('id', courseId)
            .single(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading course'));
          }
          final course = snapshot.data;
          final teacher = course?['teachers'] as Map<String, dynamic>?;
          final instructor =
              teacher?['full_name']?.toString() ?? teacher?['name']?.toString() ?? 'TBD';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.grey.shade700, Colors.grey.shade900]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course?['name'] ?? 'Course',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(course?['code'] ?? '',
                          style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (course?['progress'] as num? ?? 0).toDouble() /
                              100,
                          backgroundColor: Colors.white24,
                          color: Colors.white,
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${course?['progress'] ?? 0}% Complete',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms),
                const SizedBox(height: 24),

                // Course Info
                _CourseInfoSection(
                  title: 'Instructor',
                  icon: Icons.person,
                  content: instructor,
                ),
                _CourseInfoSection(
                  title: 'Duration',
                  icon: Icons.access_time,
                  content: course?['duration']?.toString() ?? 'TBD',
                ),
                _CourseInfoSection(
                  title: 'Credits',
                  icon: Icons.stars,
                  content: '${course?['credits'] ?? 0} credits',
                ),
                const SizedBox(height: 24),

                // Modules
                const Text('Course Modules',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                FutureBuilder(
                  future: supabase
                      .from('course_resources')
                      .select('*')
                      .eq('course_id', courseId)
                      .order('upload_date'),
                  builder: (context, moduleSnapshot) {
                    if (moduleSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final modules =
                        moduleSnapshot.data as List? ?? [];
                    if (modules.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: Text('No modules yet')),
                      );
                    }
                    return Column(
                      children: modules
                          .map((m) => _ModuleTile(
                                title: m['title']?.toString() ?? 'Module',
                                lessons: 1,
                                duration:
                                    m['type']?.toString() ?? 'resource',
                                completed:
                                    (m['download_count'] ?? 0) > 0,
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 2. Assignment Submission Screen
class AssignmentSubmissionScreen extends ConsumerStatefulWidget {
  final String assignmentId;
  const AssignmentSubmissionScreen({super.key, required this.assignmentId});

  @override
  ConsumerState<AssignmentSubmissionScreen> createState() =>
      _AssignmentSubmissionScreenState();
}

class _AssignmentSubmissionScreenState
    extends ConsumerState<AssignmentSubmissionScreen> {
  String? _selectedFile;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Assignment'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assignment Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Assignment Details',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    FutureBuilder(
                      future: Supabase.instance.client
                          .from('homework')
                          .select('*, subjects(name)')
                          .eq('id', widget.assignmentId)
                          .maybeSingle(),
                      builder: (context, snapshot) {
                        final hw = snapshot.data;
                        final subject = (hw?['subjects'] as Map?)?['name']
                                ?.toString() ??
                            'Course';
                        return Column(
                          children: [
                            _DetailRow('Title',
                                hw?['title']?.toString() ?? 'Assignment'),
                            _DetailRow('Course', subject),
                            _DetailRow('Due Date',
                                _formatDate(hw?['due_date'])),
                            _DetailRow('Status',
                                hw?['status']?.toString() ?? 'Active'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // File Upload
            const Text('Upload File',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                setState(() => _selectedFile = 'research_paper.pdf');
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black87, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withValues(alpha: 0.05),
                ),
                child: Column(
                  children: [
                    Icon(
                        _selectedFile != null
                            ? Icons.insert_drive_file
                            : Icons.cloud_upload,
                        size: 48,
                        color: Colors.black87),
                    const SizedBox(height: 8),
                    Text(_selectedFile ?? 'Tap to select file',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('PDF, DOC, DOCX (Max 10MB)',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            const Text('Additional Notes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add any notes for your instructor...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            FilledButton.icon(
              onPressed: _selectedFile == null
                  ? null
                  : () => _submitAssignment(),
              icon: const Icon(Icons.send),
              label: const Text('Submit Assignment'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitAssignment() async {
    try {
      final supabase = Supabase.instance.client;
      // Resolve the real student record for this user.
      final studentRows = await supabase
          .from('students')
          .select('id')
          .eq('profile_id', supabase.auth.currentUser?.id ?? '')
          .limit(1);
      final studentId =
          (studentRows.isNotEmpty ? studentRows.first['id'] : null) as String?;
      await supabase.from('homework_submissions').insert({
        'homework_id': widget.assignmentId,
        'student_id': studentId,
        'submission_text': _notesController.text.trim(),
        'submitted_at': DateTime.now().toIso8601String(),
        'status': 'submitted',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Assignment submitted successfully!'),
              backgroundColor: Colors.black87),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
    } catch (e) {
      return 'N/A';
    }
  }
}

/// 3. Timetable View Screen
class TimetableViewScreen extends ConsumerWidget {
  const TimetableViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final now = DateTime.now();
    final currentDay = now.weekday - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Timetable'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: Supabase.instance.client
            .from('timetables')
            .select('*, subjects(name), teachers(full_name)')
            .order('day_of_week'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final rows = snapshot.data as List? ?? [];
          final byDay = <int, List<Map<String, dynamic>>>{};
          for (final r in rows) {
            final d = (r['day_of_week'] as num?)?.toInt() ?? 1;
            byDay.putIfAbsent(d, () => []).add(r);
          }

          if (rows.isEmpty) {
            return const Center(child: Text('No classes scheduled'));
          }

          return DefaultTabController(
            length: days.length,
            initialIndex: currentDay < 5 ? currentDay : 0,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs:
                      days.map((day) => Tab(text: day.substring(0, 3))).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: days.map((day) {
                      final dayRows = byDay[days.indexOf(day) + 1] ?? [];
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: dayRows.length,
                        itemBuilder: (context, index) {
                          final row = dayRows[index];
                          final subject =
                              (row['subjects'] as Map?)?['name']?.toString() ??
                                  'Subject';
                          final teacher =
                              (row['teachers'] as Map?)?['full_name']
                                      ?.toString() ??
                                  '';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                    row['start_time']?.toString() ?? '',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade800,
                                        fontWeight: FontWeight.bold)),
                              ),
                              title: Text(subject,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  '${row['end_time'] ?? ''} • $teacher'),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 4. Subject-wise Progress Screen
class SubjectProgressScreen extends ConsumerWidget {
  const SubjectProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject Progress'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: () async {
          final supabase = Supabase.instance.client;
          final studentRows = await supabase
              .from('students')
              .select('id')
              .eq('profile_id', userId ?? '')
              .limit(1);
          final studentId =
              (studentRows.isNotEmpty ? studentRows.first['id'] : null)
                  as String?;
          if (studentId == null) return <Map<String, dynamic>>[];
          final data = await supabase
              .from('student_progress')
              .select('*')
              .eq('student_id', studentId);
          return (data as List).cast<Map<String, dynamic>>();
        }(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final progress = snapshot.data as List? ?? [];

          if (progress.isEmpty) {
            return const Center(child: Text('No progress records yet'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: progress
                .map((p) {
                  final total =
                      (p['assignments_total'] as num?)?.toInt() ?? 0;
                  final done =
                      (p['assignments_completed'] as num?)?.toInt() ?? 0;
                  final pct = total > 0 ? (done / total * 100).round() : 0;
                  return _SubjectProgressCard(
                      subject: p['subject']?.toString() ?? 'Subject',
                      progress: pct,
                      grade: p['performance_trend']?.toString() ?? '—',
                      color: Colors.black87);
                })
                .toList(),
          );
        },
      ),
    );
  }
}

/// 5. Study Planner Screen
class StudyPlannerScreen extends ConsumerWidget {
  const StudyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Planner'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: FutureBuilder(
        future: Supabase.instance.client
            .from('homework')
            .select('*, subjects(name)')
            .order('due_date'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final tasks = snapshot.data as List? ?? [];

          if (tasks.isEmpty) {
            return const Center(child: Text('No assignments yet'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Today',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...tasks.map((t) {
                final subject =
                    (t['subjects'] as Map?)?['name']?.toString() ?? 'General';
                final due = t['due_date']?.toString().split('T').first ?? '';
                return _StudyTaskTile(
                    title: t['title']?.toString() ?? 'Task',
                    subject: subject,
                    time: due,
                    priority: t['status']?.toString() == 'active'
                        ? 'High'
                        : 'Medium');
              }),
            ],
          );
        },
      ),
    );
  }
}

/// 6. Online Classes Screen
class OnlineClassesScreen extends ConsumerWidget {
  const OnlineClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Classes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: Supabase.instance.client
            .from('events')
            .select('*')
            .eq('event_type', 'online_class')
            .order('start_date'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final classes = snapshot.data as List? ?? [];

          if (classes.isEmpty) {
            return const Center(child: Text('No online classes scheduled'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final cls = classes[index];
              final status = cls['status']?.toString() ?? 'upcoming';
              final isLive = status.toLowerCase() == 'live';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isLive
                              ? Colors.red.shade100
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isLive ? Icons.videocam : Icons.schedule,
                          color: isLive ? Colors.red : Colors.black87,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(cls['title'] ?? 'Class',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                ),
                                if (isLive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: const Text('LIVE',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            Text(cls['location']?.toString() ?? '',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                    fontSize: 13)),
                            Text(
                                _formatDateTime(cls['start_date']) ?? '',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      if (isLive)
                        FilledButton(
                          onPressed: () {},
                          child: const Text('Join'),
                        )
                      else
                        const Chip(label: Text('Scheduled')),
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

  String? _formatDateTime(dynamic date) {
    if (date == null) return null;
    try {
      return DateFormat('MMM dd, hh:mm a').format(DateTime.parse(date));
    } catch (_) {
      return null;
    }
  }
}

/// 7. Career Guidance Screen
class CareerGuidanceScreen extends StatelessWidget {
  const CareerGuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentLifestylePage(
      title: 'Career Guidance',
      tableName: 'career_guidance',
      icon: Icons.explore,
      fields: ['title', 'category', 'description'],
      accent: Color(0xFF475569),
    );
  }
}

/// 8. Scholarship Applications Screen
class ScholarshipScreen extends StatelessWidget {
  const ScholarshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentLifestylePage(
      title: 'Scholarships',
      tableName: 'scholarships',
      icon: Icons.workspace_premium,
      fields: ['title', 'provider', 'amount', 'deadline'],
      accent: Color(0xFFCA8A04),
    );
  }
}

/// 9. Sports Activities Screen
class SportsActivitiesScreen extends StatelessWidget {
  const SportsActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentLifestylePage(
      title: 'Sports Activities',
      tableName: 'sports_activities',
      icon: Icons.sports_soccer,
      fields: ['name', 'coach', 'schedule', 'location'],
      accent: Color(0xFF16A34A),
    );
  }
}

/// 10. Mental Health Screen
class MentalHealthScreen extends StatelessWidget {
  const MentalHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentLifestylePage(
      title: 'Mental Health',
      tableName: 'mental_health_resources',
      icon: Icons.favorite_outline,
      fields: ['title', 'counselor', 'phone', 'description'],
      accent: Color(0xFFDB2777),
    );
  }
}

/// Grades detail (subject / score breakdown)
class GradesDetailScreen extends StatelessWidget {
  const GradesDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentLifestylePage(
      title: 'Grades Detail',
      tableName: 'grades',
      icon: Icons.grade_outlined,
      fields: ['subject', 'grade', 'score', 'percentage', 'status'],
      accent: Color(0xFF2563EB),
    );
  }
}

/// Discussion forum posts
class DiscussionForumScreen extends StatelessWidget {
  const DiscussionForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentLifestylePage(
      title: 'Discussion Forum',
      tableName: 'forum_posts',
      icon: Icons.forum_outlined,
      fields: ['title', 'category', 'status', 'comment_count'],
      accent: Color(0xFF7C3AED),
    );
  }
}

/// Student project tracker
class ProjectManagementScreen extends StatelessWidget {
  const ProjectManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentLifestylePage(
      title: 'Project Management',
      tableName: 'student_projects',
      icon: Icons.account_tree_outlined,
      fields: ['title', 'status', 'due_date', 'progress'],
      accent: Color(0xFF0D9488),
    );
  }
}

/// Internship applications / placements
class InternshipTrackerScreen extends StatelessWidget {
  const InternshipTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentLifestylePage(
      title: 'Internship Tracker',
      tableName: 'internships',
      icon: Icons.work_outline,
      fields: ['company', 'role', 'status', 'start_date'],
      accent: Color(0xFFEA580C),
    );
  }
}

/// 5. Exchange Programs Screen
class ExchangeProgramsScreen extends StatelessWidget {
  const ExchangeProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentLifestylePage(
      title: 'Exchange Programs',
      tableName: 'exchange_programs',
      icon: Icons.public,
      fields: ['title', 'country', 'duration', 'deadline'],
      accent: Color(0xFF0284C7),
    );
  }
}

/// 6. Student Clubs Screen
class StudentClubsScreen extends ConsumerWidget {
  const StudentClubsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Clubs'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: supabase.from('student_groups').select('*, teachers(full_name)'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final clubs = snapshot.data as List? ?? [];

          if (clubs.isEmpty) {
            return const Center(child: Text('No clubs available'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              final club = clubs[index];
              final teacher =
                  (club['teachers'] as Map?)?['full_name']?.toString() ?? '';
              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.black87.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.groups,
                              color: Colors.black87, size: 32),
                        ),
                        const SizedBox(height: 10),
                        Text(club['name']?.toString() ?? 'Club',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 4),
                        Text(teacher,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                                fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(club['description']?.toString() ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                                fontSize: 10)),
                        const SizedBox(height: 8),
                        FilledButton.tonal(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: const Text('Join',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: (60 * index).ms, duration: 400.ms);
            },
          );
        },
      ),
    );
  }
}

/// 7. Campus Map Screen
class CampusMapScreen extends StatelessWidget {
  const CampusMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentLifestylePage(
      title: 'Campus Map',
      tableName: 'campus_locations',
      icon: Icons.map_outlined,
      fields: ['name', 'building', 'floor', 'description'],
      accent: Color(0xFF0F766E),
    );
  }
}

/// 8. Student Marketplace Screen
class StudentMarketplaceScreen extends StatelessWidget {
  const StudentMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentLifestylePage(
      title: 'Marketplace',
      tableName: 'marketplace_listings',
      icon: Icons.storefront_outlined,
      fields: ['title', 'price', 'category', 'status'],
      accent: Color(0xFF7C3AED),
    );
  }
}

/// 1. Exam Preparation Screen
class ExamPreparationScreen extends ConsumerWidget {
  const ExamPreparationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Preparation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: supabase
            .from('exams')
            .select('*')
            .gte('exam_date', DateTime.now().toIso8601String())
            .order('exam_date', ascending: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDashboard();
          }
          final exams = snapshot.data as List? ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Study Stats
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade600, Colors.purple.shade700],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Exam Ready?',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Review your upcoming exams',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.school, color: Colors.white54, size: 48),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms),
              const SizedBox(height: 24),

              if (exams.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.event_available,
                            size: 48,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6)),
                        const SizedBox(height: 12),
                        Text('No upcoming exams',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
                )
              else ...[
                const Text('Upcoming Exams',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...exams.take(5).map((exam) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.quiz, color: Colors.purple),
                      ),
                      title: Text(exam['title'] ?? 'Exam',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${exam['subject'] ?? ''} • ${exam['date'] ?? ''}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Chip(
                        label: Text(exam['exam_type'] ?? 'Exam',
                            style: const TextStyle(fontSize: 10)),
                        backgroundColor: Colors.purple.shade50,
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms);
                }),
              ],

              const SizedBox(height: 24),
              const Text('Study Resources',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _StudyCard(
                    title: 'Past Papers',
                    icon: Icons.description,
                    color: Colors.black87,
                    count: '12 available',
                  ),
                  _StudyCard(
                    title: 'Flashcards',
                    icon: Icons.style,
                    color: Colors.orange,
                    count: '48 cards',
                  ),
                  _StudyCard(
                    title: 'Practice Tests',
                    icon: Icons.fact_check,
                    color: Colors.black87,
                    count: '8 tests',
                  ),
                  _StudyCard(
                    title: 'Video Lessons',
                    icon: Icons.play_circle,
                    color: Colors.red,
                    count: '24 videos',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 2. Tutoring Screen
class TutoringScreen extends StatelessWidget {
  const TutoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentLifestylePage(
      title: 'Tutoring',
      tableName: 'tutoring_sessions',
      icon: Icons.school_outlined,
      fields: ['tutor_name', 'subject', 'rate', 'availability'],
      accent: Color(0xFF2563EB),
    );
  }
}

/// 3. Wellness & Fitness Screen
class WellnessScreen extends StatelessWidget {
  const WellnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentLifestylePage(
      title: 'Wellness',
      tableName: 'wellness_resources',
      icon: Icons.self_improvement,
      fields: ['title', 'category', 'description', 'contact'],
      accent: Color(0xFF059669),
    );
  }
}

/// 4. Lost & Found Screen
class LostAndFoundScreen extends StatelessWidget {
  const LostAndFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentLifestylePage(
      title: 'Lost & Found',
      tableName: 'lost_and_found',
      icon: Icons.find_in_page_outlined,
      fields: ['item_name', 'location_found', 'status', 'description'],
      accent: Color(0xFFEA580C),
    );
  }
}

/// 5. Canteen / Food Ordering Screen
class CanteenScreen extends StatelessWidget {
  const CanteenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentLifestylePage(
      title: 'Canteen',
      tableName: 'canteen_items',
      icon: Icons.restaurant_menu,
      fields: ['name', 'category', 'price', 'available'],
      accent: Color(0xFFDC2626),
    );
  }
}

/// 6. Attendance Calendar Screen
class AttendanceCalendarScreen extends ConsumerWidget {
  const AttendanceCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Calendar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Month view header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: const Icon(Icons.chevron_left), onPressed: () {}),
                const Text('March 2025',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                    icon: const Icon(Icons.chevron_right), onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              final day = index + 1;
              if (day > 31) return const SizedBox.shrink();

              // Simulate attendance status
              final status = day <= 20
                  ? (day % 7 == 0
                      ? 'absent'
                      : day % 5 == 0
                          ? 'late'
                          : 'present')
                  : null;

              Color? bgColor;
              if (status == 'present') {
                bgColor = Colors.black.withValues(alpha: 0.2);
              } else if (status == 'absent') {
                bgColor = Colors.red.withValues(alpha: 0.2);
              } else if (status == 'late') {
                bgColor = Colors.orange.withValues(alpha: 0.2);
              }

              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    day <= 31 ? '$day' : '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: status == 'absent'
                          ? Colors.red
                          : status == 'late'
                              ? Colors.orange
                              : null,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: Colors.black87, label: 'Present'),
              const SizedBox(width: 16),
              _LegendItem(color: Colors.red, label: 'Absent'),
              const SizedBox(width: 16),
              _LegendItem(color: Colors.orange, label: 'Late'),
            ],
          ),
          const SizedBox(height: 24),

          // Stats
          Row(
            children: [
              _AttendanceStat(
                  label: 'Present',
                  value: '18',
                  total: '22',
                  color: Colors.black87),
              const SizedBox(width: 12),
              _AttendanceStat(
                  label: 'Absent', value: '2', total: '22', color: Colors.red),
              const SizedBox(width: 12),
              _AttendanceStat(
                  label: 'Late', value: '2', total: '22', color: Colors.orange),
            ],
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
        ],
      ),
    );
  }
}

/// 7. Student ID / Digital Card Screen
class StudentIdScreen extends ConsumerWidget {
  const StudentIdScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student ID'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: FutureBuilder(
          future: supabase
              .from('users')
              .select('*')
              .eq('id', userId ?? '')
              .single(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SkeletonDashboard();
            }
            final profile = snapshot.data;

            return Container(
              width: 340,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey.shade800, Colors.grey.shade900],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.school, color: Colors.white, size: 32),
                      const SizedBox(width: 8),
                      const Text('STUDENT ID',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('ACTIVE',
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Icon(Icons.person, color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(profile?['full_name'] ?? 'Student Name',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(profile?['email'] ?? 'student@school.edu',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _IdInfo(label: 'ID Number', value: 'STU-2025-0042'),
                      _IdInfo(label: 'Class', value: 'Grade 10-A'),
                      _IdInfo(label: 'Year', value: '2024-25'),
                    ],
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
          },
        ),
      ),
    );
  }
}

/// 8. Notifications Preferences Screen
class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final Map<String, bool> _prefs = {
    'assignment_reminders': true,
    'grade_updates': true,
    'exam_schedules': true,
    'attendance_alerts': false,
    'messages': true,
    'announcements': true,
    'forum_replies': false,
    'fee_reminders': true,
    'event_updates': true,
    'push': true,
    'email': false,
  };
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final rows = await Supabase.instance.client
          .from('notification_preferences')
          .select('push_enabled, email_enabled, in_app_enabled')
          .eq('user_id', userId)
          .limit(1);
      if (rows.isNotEmpty) {
        final r = Map<String, dynamic>.from(rows.first);
        _prefs['push'] = r['push_enabled'] == true;
        _prefs['email'] = r['email_enabled'] == true;
      }
    } catch (_) {
      // Preferences table may be empty; keep defaults.
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _set(String key, bool value) async {
    setState(() => _prefs[key] = value);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    if (key == 'push' || key == 'email') {
      try {
        await Supabase.instance.client.from('notification_preferences').upsert({
          'user_id': userId,
          'push_enabled': _prefs['push'] ?? true,
          'email_enabled': _prefs['email'] ?? false,
          'in_app_enabled': true,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'Notification Settings',
      body: _loading
          ? const Center(child: AdaptiveProgress())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Academic',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _NotifSwitch(
                  title: 'Assignment Reminders',
                  subtitle: 'Before due dates',
                  value: _prefs['assignment_reminders']!,
                  onChanged: (v) => _set('assignment_reminders', v),
                ),
                _NotifSwitch(
                  title: 'Grade Updates',
                  subtitle: 'When grades are posted',
                  value: _prefs['grade_updates']!,
                  onChanged: (v) => _set('grade_updates', v),
                ),
                _NotifSwitch(
                  title: 'Exam Schedules',
                  subtitle: 'Upcoming exam alerts',
                  value: _prefs['exam_schedules']!,
                  onChanged: (v) => _set('exam_schedules', v),
                ),
                _NotifSwitch(
                  title: 'Attendance Alerts',
                  subtitle: 'When marked absent',
                  value: _prefs['attendance_alerts']!,
                  onChanged: (v) => _set('attendance_alerts', v),
                ),
                const SizedBox(height: 24),
                const Text('Communication',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _NotifSwitch(
                  title: 'Messages',
                  subtitle: 'New messages from teachers',
                  value: _prefs['messages']!,
                  onChanged: (v) => _set('messages', v),
                ),
                _NotifSwitch(
                  title: 'Announcements',
                  subtitle: 'School-wide announcements',
                  value: _prefs['announcements']!,
                  onChanged: (v) => _set('announcements', v),
                ),
                _NotifSwitch(
                  title: 'Forum Replies',
                  subtitle: 'When someone replies',
                  value: _prefs['forum_replies']!,
                  onChanged: (v) => _set('forum_replies', v),
                ),
                const SizedBox(height: 24),
                const Text('System',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _NotifSwitch(
                  title: 'Fee Reminders',
                  subtitle: 'Payment due dates',
                  value: _prefs['fee_reminders']!,
                  onChanged: (v) => _set('fee_reminders', v),
                ),
                _NotifSwitch(
                  title: 'Event Updates',
                  subtitle: 'School events and activities',
                  value: _prefs['event_updates']!,
                  onChanged: (v) => _set('event_updates', v),
                ),
                _NotifSwitch(
                  title: 'Push Notifications',
                  subtitle: 'Enable push alerts',
                  value: _prefs['push']!,
                  onChanged: (v) => _set('push', v),
                ),
                _NotifSwitch(
                  title: 'Email Notifications',
                  subtitle: 'Receive via email',
                  value: _prefs['email']!,
                  onChanged: (v) => _set('email', v),
                ),
              ],
            ),
    );
  }
}

// Helper widgets
class _StudyCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String count;

  const _StudyCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              Text(count,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _AttendanceStat extends StatelessWidget {
  final String label;
  final String value;
  final String total;
  final Color color;

  const _AttendanceStat({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text('$value/$total',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }
}

class _IdInfo extends StatelessWidget {
  final String label;
  final String value;

  const _IdInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ],
    );
  }
}

class _NotifSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: AdaptiveSwitch(value: value, onChanged: onChanged),
    );
  }
}

/// Library Books Screen - Borrowed books
class StudentLibraryScreen extends ConsumerWidget {
  const StudentLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: supabase
            .from('book_issues')
            .select('*, library_books(*)')
            .eq('student_id', userId ?? '')
            .order('issue_date', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonList();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final books = snapshot.data as List? ?? [];

          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'No books borrowed',
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Visit the library to borrow books',
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6)),
                  ),
                ],
              ),
            );
          }

          // Statistics
          final activeBooks =
              books.where((b) => b['status'] == 'Issued').length;
          final overdueBooks = books.where((b) {
            if (b['due_date'] == null) return false;
            try {
              return DateTime.parse(b['due_date']).isBefore(DateTime.now()) &&
                  b['status'] == 'Issued';
            } catch (e) {
              return false;
            }
          }).length;
          final totalFines = books.fold<double>(
            0,
            (sum, b) => sum + (b['fine_amount'] as num? ?? 0).toDouble(),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Row
                Row(
                  children: [
                    _StatCard(
                      title: 'Active Books',
                      value: activeBooks.toString(),
                      icon: Icons.book,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      title: 'Overdue',
                      value: overdueBooks.toString(),
                      icon: Icons.warning,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      title: 'Total Fines',
                      value: '\$${totalFines.toStringAsFixed(2)}',
                      icon: Icons.attach_money,
                      color: Colors.orange,
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms),
                const SizedBox(height: 24),

                // Book List
                const Text(
                  'Borrowed Books',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                ...books.map((book) {
                  final bookInfo =
                      book['library_books'] as Map<String, dynamic>?;
                  final isOverdue = book['status'] == 'Issued' &&
                      book['due_date'] != null &&
                      DateTime.tryParse(book['due_date'])
                              ?.isBefore(DateTime.now()) ==
                          true;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.brown.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child:
                                Icon(Icons.book, color: Colors.brown.shade700),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bookInfo?['title'] ?? 'Unknown Book',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  bookInfo?['author'] ?? 'Unknown Author',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _StatusChip(
                                      label: book['status'] ?? 'Unknown',
                                      color: _getStatusColor(
                                          context, book['status']),
                                    ),
                                    const SizedBox(width: 8),
                                    if (isOverdue)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade100,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'OVERDUE',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Due: ${_formatDate(book['due_date'])}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isOverdue
                                      ? Colors.red
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                ),
                              ),
                              if ((book['fine_amount'] as num? ?? 0) > 0)
                                Text(
                                  'Fine: \$${(book['fine_amount'] as num).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(
                      delay: (100 * books.indexOf(book)).ms, duration: 400.ms);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String? status) {
    switch (status) {
      case 'Issued':
        return Colors.black87;
      case 'Returned':
        return Colors.black87;
      case 'Overdue':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
    } catch (e) {
      return 'Invalid';
    }
  }
}

/// Notifications Screen
class StudentNotificationsScreen extends ConsumerWidget {
  const StudentNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              await supabase
                  .from('notifications')
                  .update({
                    'is_read': true,
                    'read_at': DateTime.now().toIso8601String()
                  })
                  .eq('user_id', userId ?? '')
                  .eq('is_read', false);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('All notifications marked as read')),
                );
              }
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: supabase
            .from('notifications')
            .select('*')
            .eq('user_id', userId ?? '')
            .order('created_at', ascending: false)
            .limit(50),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonList();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final notifications = snapshot.data as List? ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6)),
                  ),
                ],
              ),
            );
          }

          // Group by date
          final today = <Map<String, dynamic>>[];
          final yesterday = <Map<String, dynamic>>[];
          final older = <Map<String, dynamic>>[];

          final now = DateTime.now();
          for (var n in notifications) {
            if (n['created_at'] == null) continue;
            try {
              final date = DateTime.parse(n['created_at']);
              if (date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day) {
                today.add(n);
              } else if (date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day - 1) {
                yesterday.add(n);
              } else {
                older.add(n);
              }
            } catch (e) {
              older.add(n);
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (today.isNotEmpty) ...[
                const Text('Today',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...today.map((n) => _NotificationTile(notification: n)),
                const SizedBox(height: 16),
              ],
              if (yesterday.isNotEmpty) ...[
                const Text('Yesterday',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...yesterday.map((n) => _NotificationTile(notification: n)),
                const SizedBox(height: 16),
              ],
              if (older.isNotEmpty) ...[
                const Text('Earlier',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...older.map((n) => _NotificationTile(notification: n)),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Feedback Screen
class StudentFeedbackScreen extends ConsumerStatefulWidget {
  const StudentFeedbackScreen({super.key});

  @override
  ConsumerState<StudentFeedbackScreen> createState() =>
      _StudentFeedbackScreenState();
}

class _StudentFeedbackScreenState extends ConsumerState<StudentFeedbackScreen> {
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  int _rating = 5;
  String _feedbackType = 'general';
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _feedbackCategories = [];
  bool _categoriesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    // Feedback categories are fixed system values.
    _feedbackCategories = [
      {'value': 'general', 'name': 'General'},
      {'value': 'course', 'name': 'Course'},
      {'value': 'teacher', 'name': 'Teacher'},
      {'value': 'facility', 'name': 'Facilities'},
      {'value': 'service', 'name': 'Service'},
    ];
    if (mounted) setState(() => _categoriesLoaded = true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_titleController.text.isEmpty || _commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    try {
      await supabase.from('feedback').insert({
        'user_id': userId,
        'feedback_type': _feedbackType,
        'title': _titleController.text,
        'comment': _commentController.text,
        'rating': _rating,
        'status': 'pending',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.black87,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Feedback'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Help us improve!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your feedback helps us provide a better experience',
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 32),

            // Rating
            const Text('Rating', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Feedback Type
            const Text('Category',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _feedbackType,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _categoriesLoaded && _feedbackCategories.isNotEmpty
                  ? _feedbackCategories
                      .map((c) => DropdownMenuItem(
                            value: c['id'] as String? ??
                                c['value'] as String? ??
                                c['name'] as String? ??
                                'general',
                            child: Text(c['name'] as String? ??
                                c['label'] as String? ??
                                'General'),
                          ))
                      .toList()
                  : const [
                      DropdownMenuItem(
                          value: 'general', child: Text('General')),
                      DropdownMenuItem(value: 'course', child: Text('Course')),
                      DropdownMenuItem(
                          value: 'teacher', child: Text('Teacher')),
                      DropdownMenuItem(
                          value: 'facility', child: Text('Facilities')),
                      DropdownMenuItem(
                          value: 'service', child: Text('Service')),
                    ],
              onChanged: (v) => setState(() => _feedbackType = v ?? 'general'),
            ),
            const SizedBox(height: 24),

            // Title
            const Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Brief title of your feedback',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // Comment
            const Text('Details',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _commentController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Tell us more about your experience...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submitFeedback,
              icon: const Icon(Icons.send),
              label: Text(_isSubmitting ? 'Submitting...' : 'Submit Feedback'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

/// Study Materials Screen
class StudyMaterialsScreen extends ConsumerWidget {
  const StudyMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Materials'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: supabase
            .from('course_resources')
            .select('*')
            .order('upload_date', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonList();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final resources = snapshot.data as List? ?? [];

          if (resources.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'No study materials',
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6)),
                  ),
                ],
              ),
            );
          }

          // Group by type
          final byType = <String, List>{};
          for (var r in resources) {
            final type = r['type']?.toString() ?? 'Other';
            byType.putIfAbsent(type, () => []).add(r);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Quick Stats
              Row(
                children: [
                  _StatCard(
                    title: 'Total Files',
                    value: resources.length.toString(),
                    icon: Icons.folder,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    title: 'PDFs',
                    value: (byType['PDF']?.length ?? 0).toString(),
                    icon: Icons.picture_as_pdf,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    title: 'Videos',
                    value: (byType['Video']?.length ?? 0).toString(),
                    icon: Icons.video_library,
                    color: Colors.purple,
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms),
              const SizedBox(height: 24),

              // By Type
              ...byType.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...entry.value.map((r) => _ResourceTile(resource: r)),
                    const SizedBox(height: 16),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

// Helper Widgets
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isRead = notification['is_read'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isRead
            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)
              : Colors.grey.shade400,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTypeColor(context, notification['type']),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTypeIcon(notification['type']),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification['title'] ?? 'Notification',
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['body'] ?? ''),
            const SizedBox(height: 4),
            Text(
              _formatDate(notification['created_at']),
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6)),
            ),
          ],
        ),
        trailing: isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: Colors.black87, shape: BoxShape.circle)),
        onTap: () async {
          if (!isRead) {
            await Supabase.instance.client.from('notifications').update({
              'is_read': true,
              'read_at': DateTime.now().toIso8601String()
            }).eq('id', notification['id']);
          }
        },
      ),
    );
  }

  Color _getTypeColor(BuildContext context, String? type) {
    switch (type) {
      case 'academic':
        return Colors.black87;
      case 'payment':
        return Colors.black87;
      case 'attendance':
        return Colors.orange;
      case 'exam':
        return Colors.purple;
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'academic':
        return Icons.school;
      case 'payment':
        return Icons.payments;
      case 'attendance':
        return Icons.check_circle;
      case 'exam':
        return Icons.quiz;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final dt = DateTime.parse(date);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return DateFormat('MMM dd, hh:mm a').format(dt);
    } catch (e) {
      return '';
    }
  }
}

class _ResourceTile extends StatelessWidget {
  final Map<String, dynamic> resource;
  const _ResourceTile({required this.resource});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTypeColor(context, resource['type']),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getTypeIcon(resource['type']), color: Colors.white),
        ),
        title: Text(resource['title'] ?? 'Resource'),
        subtitle: Text(
          resource['type']?.toString() ?? 'Unknown',
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (resource['download_count'] != null)
              Text(
                '${resource['download_count']} downloads',
                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6)),
              ),
            const Icon(Icons.download),
          ],
        ),
        onTap: () {
          // Download logic
        },
      ),
    );
  }

  Color _getTypeColor(BuildContext context, String? type) {
    switch (type) {
      case 'PDF':
        return Colors.red;
      case 'Video':
        return Colors.purple;
      case 'Document':
        return Colors.black87;
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'Video':
        return Icons.video_library;
      case 'Document':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}

/// Fee Details Screen - Comprehensive fee breakdown
class FeeDetailsScreen extends ConsumerWidget {
  const FeeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: Future.wait([
          supabase
              .from('student_fee_assignments')
              .select('*, fee_structures(*), academic_years(*)')
              .eq('student_id', userId ?? '')
              .order('created_at', ascending: false),
          supabase
              .from('payments')
              .select('*')
              .eq('student_id', userId ?? '')
              .order('payment_date', ascending: false),
          supabase
              .from('installment_plans')
              .select('*')
              .order('due_date', ascending: true),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonList();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          }

          final results = snapshot.data as List;
          final assignments = results[0] as List? ?? [];
          final payments = results[1] as List? ?? [];

          // Calculate totals
          final totalAmount = assignments.fold<double>(
            0,
            (sum, a) => sum + (a['total_amount'] as num? ?? 0).toDouble(),
          );
          final paidAmount = assignments.fold<double>(
            0,
            (sum, a) => sum + (a['paid_amount'] as num? ?? 0).toDouble(),
          );
          final balanceAmount = totalAmount - paidAmount;
          final paymentProgress =
              totalAmount > 0 ? (paidAmount / totalAmount) : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment Summary Card
                _PaymentSummaryCard(
                  totalAmount: totalAmount,
                  paidAmount: paidAmount,
                  balanceAmount: balanceAmount,
                  progress: paymentProgress,
                ).animate().fadeIn(duration: 600.ms),
                const SizedBox(height: 24),

                // Fee Assignments
                const Text(
                  'Fee Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...assignments.map((a) => _FeeAssignmentCard(assignment: a)),
                const SizedBox(height: 24),

                // Payment History
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment History',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // Download receipt
                      },
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Export'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...payments
                    .take(10)
                    .map((p) => _PaymentHistoryTile(payment: p)),

                if (payments.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No payment history',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6)),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Help & Support Screen
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // FAQ Section
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _FaqTile(
            question: 'How do I view my grades?',
            answer:
                'Navigate to the Grades section from your dashboard to view all your current and past grades.',
          ),
          _FaqTile(
            question: 'How can I submit an assignment?',
            answer:
                'Go to Assignments, select the assignment you want to submit, and click the Submit button to upload your work.',
          ),
          _FaqTile(
            question: 'Where can I find my schedule?',
            answer:
                'Your class schedule is available in the Schedule section, accessible from the main dashboard.',
          ),
          _FaqTile(
            question: 'How do I pay my fees?',
            answer:
                'Navigate to Fee Payment or Fee Details to view your fee breakdown and make payments online.',
          ),
          _FaqTile(
            question: 'Can I download my certificates?',
            answer:
                'Yes, all your earned certificates are available in the Certificates section and can be downloaded anytime.',
          ),
          const SizedBox(height: 24),

          // Contact Support
          const Text(
            'Contact Support',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _ContactOption(
            icon: Icons.email,
            title: 'Email Support',
            subtitle: 'support@example.com',
            onTap: () {},
          ),
          _ContactOption(
            icon: Icons.phone,
            title: 'Phone Support',
            subtitle: '+1 234 567 890',
            onTap: () {},
          ),
          _ContactOption(
            icon: Icons.chat,
            title: 'Live Chat',
            subtitle: 'Available 9am - 5pm',
            onTap: () {},
          ),
          const SizedBox(height: 24),

          // Submit Ticket
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _SubmitTicketScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Submit Support Ticket'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

/// Privacy & Security Screen
class PrivacySecurityScreen extends ConsumerWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Security Settings
          const Text(
            'Security Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _SecurityOption(
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () => Navigator.pushNamed(context, '/change-password'),
          ),
          _SecurityOption(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            subtitle: 'Enable fingerprint/face ID',
            trailing: Switch(
              value: false,
              onChanged: (v) {},
            ),
          ),
          _SecurityOption(
            icon: Icons.devices,
            title: 'Logged-in Devices',
            subtitle: 'Manage your active sessions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _DevicesScreen()),
              );
            },
          ),
          const SizedBox(height: 24),

          // Privacy
          const Text(
            'Privacy',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _SecurityOption(
            icon: Icons.notifications_off,
            title: 'Notification Preferences',
            subtitle: 'Manage what notifications you receive',
            onTap: () {},
          ),
          _SecurityOption(
            icon: Icons.visibility_off,
            title: 'Profile Visibility',
            subtitle: 'Control who can see your profile',
            onTap: () {},
          ),
          _SecurityOption(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            titleColor: Colors.red,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Account?'),
                  content: const Text(
                    'This action cannot be undone. All your data will be permanently deleted.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Data
          const Text(
            'Your Data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _SecurityOption(
            icon: Icons.download,
            title: 'Download My Data',
            subtitle: 'Export all your personal data',
            onTap: () {},
          ),
          _SecurityOption(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {},
          ),
          _SecurityOption(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'Read our terms and conditions',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// Achievements Screen
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: () async {
          // Resolve the real student record before querying progress.
          final studentRows = await supabase
              .from('students')
              .select('id')
              .eq('profile_id', userId ?? '')
              .limit(1);
          final studentId =
              (studentRows.isNotEmpty ? studentRows.first['id'] : null)
                  as String?;
          if (studentId == null) {
            return [<Map<String, dynamic>>[], <Map<String, dynamic>>[]];
          }
          return Future.wait([
            supabase
                .from('student_progress')
                .select('*')
                .eq('student_id', studentId),
            supabase
                .from('certificates')
                .select('*')
                .eq('student_id', studentId)
                .eq('status', 'issued'),
          ]);
        }(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonList();
          }

          final results = snapshot.data as List;
          final certificates = results[1] as List? ?? [];

          final achievements = <_Achievement>[
            _Achievement(
              icon: Icons.emoji_events,
              title: 'Course Champion',
              description: 'Complete 5 courses',
              progress: 0.6,
              earned: false,
              color: Colors.amber,
            ),
            _Achievement(
              icon: Icons.star,
              title: 'Top Performer',
              description: 'Achieve 90%+ average grade',
              progress: 0.85,
              earned: true,
              color: Colors.purple,
            ),
            _Achievement(
              icon: Icons.school,
              title: 'Perfect Attendance',
              description: '100% attendance for a month',
              progress: 1.0,
              earned: true,
              color: Colors.black87,
            ),
            _Achievement(
              icon: Icons.assignment_turned_in,
              title: 'Assignment Master',
              description: 'Submit 50 assignments on time',
              progress: 0.4,
              earned: false,
              color: Colors.black87,
            ),
            _Achievement(
              icon: Icons.menu_book,
              title: 'Bookworm',
              description: 'Borrow 20 books from library',
              progress: 0.25,
              earned: false,
              color: Colors.orange,
            ),
            _Achievement(
              icon: Icons.card_membership,
              title: 'Certified',
              description: 'Earn 3 certificates',
              progress: certificates.length / 3,
              earned: certificates.length >= 3,
              color: Colors.black87,
            ),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade400, Colors.orange.shade600],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Achievements',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Keep learning to earn more!',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          achievements.where((a) => a.earned).length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms),
                const SizedBox(height: 24),

                // Achievements Grid
                const Text(
                  'Badges',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  children: achievements
                      .map((a) => _AchievementCard(achievement: a))
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Helper widgets
class _PaymentSummaryCard extends StatelessWidget {
  final double totalAmount;
  final double paidAmount;
  final double balanceAmount;
  final double progress;

  const _PaymentSummaryCard({
    required this.totalAmount,
    required this.paidAmount,
    required this.balanceAmount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade600, Colors.purple.shade800],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fee Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.account_balance_wallet, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _AmountItem(
                label: 'Total Fees',
                amount: totalAmount,
              ),
              _AmountItem(
                label: 'Paid',
                amount: paidAmount,
                color: Colors.black87,
              ),
              _AmountItem(
                label: 'Balance',
                amount: balanceAmount,
                color:
                    balanceAmount > 0 ? Colors.redAccent : Colors.black87,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.black87),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% paid',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AmountItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color? color;

  const _AmountItem({
    required this.label,
    required this.amount,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _FeeAssignmentCard extends StatelessWidget {
  final Map<String, dynamic> assignment;
  const _FeeAssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final structure = assignment['fee_structures'] as Map<String, dynamic>?;
    final totalAmount = (assignment['total_amount'] as num? ?? 0).toDouble();
    final paidAmount = (assignment['paid_amount'] as num? ?? 0).toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              structure?['name'] ?? 'Fee Assignment',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6)),
                ),
                Text(
                  'Paid: \$${paidAmount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: totalAmount > 0 ? paidAmount / totalAmount : 0,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.2),
              color: Colors.black87,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(context, assignment['status']),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                assignment['status']?.toString().toUpperCase() ?? 'PENDING',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String? status) {
    switch (status) {
      case 'paid':
        return Colors.black87;
      case 'partial':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }
}

class _PaymentHistoryTile extends StatelessWidget {
  final Map<String, dynamic> payment;
  const _PaymentHistoryTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.receipt_long, color: Colors.grey.shade800),
        ),
        title: Text(payment['payment_number'] ?? 'Payment'),
        subtitle: Text(
          _formatDate(payment['payment_date']),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          '\$${(payment['amount'] as num? ?? 0).toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
    } catch (e) {
      return 'Invalid';
    }
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title:
          Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(answer,
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7))),
        ),
      ],
    );
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _SecurityOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? titleColor;

  const _SecurityOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: titleColor ?? Colors.black87),
        title: Text(title, style: TextStyle(color: titleColor)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: trailing != null ? null : onTap,
      ),
    );
  }
}

class _Achievement {
  final IconData icon;
  final String title;
  final String description;
  final double progress;
  final bool earned;
  final Color color;

  _Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.progress,
    required this.earned,
    required this.color,
  });
}

class _AchievementCard extends StatelessWidget {
  final _Achievement achievement;
  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.earned
            ? achievement.color.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.earned
              ? achievement.color
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            achievement.icon,
            size: 40,
            color: achievement.earned
                ? achievement.color
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            achievement.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: achievement.earned
                  ? Colors.black87
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            achievement.description,
            style: TextStyle(
                fontSize: 10,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: achievement.progress,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
              color: achievement.color,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(achievement.progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 10,
              color: achievement.earned
                  ? achievement.color
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitTicketScreen extends StatefulWidget {
  const _SubmitTicketScreen();

  @override
  State<_SubmitTicketScreen> createState() => _SubmitTicketScreenState();
}

class _SubmitTicketScreenState extends State<_SubmitTicketScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'other';
  List<Map<String, dynamic>> _supportCategories = [];
  bool _categoriesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    // Support ticket categories are fixed system values.
    _supportCategories = [
      {'value': 'hardware', 'name': 'Hardware'},
      {'value': 'software', 'name': 'Software'},
      {'value': 'network', 'name': 'Network'},
      {'value': 'account', 'name': 'Account'},
      {'value': 'other', 'name': 'Other'},
    ];
    if (mounted) setState(() => _categoriesLoaded = true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Issue Title',
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(
                labelText: 'Category',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _categoriesLoaded && _supportCategories.isNotEmpty
                  ? _supportCategories
                      .map((c) => DropdownMenuItem(
                            value: c['id'] as String? ??
                                c['value'] as String? ??
                                c['name'] as String? ??
                                'other',
                            child: Text(c['name'] as String? ??
                                c['label'] as String? ??
                                'Other'),
                          ))
                      .toList()
                  : const [
                      DropdownMenuItem(
                          value: 'hardware', child: Text('Hardware')),
                      DropdownMenuItem(
                          value: 'software', child: Text('Software')),
                      DropdownMenuItem(
                          value: 'network', child: Text('Network')),
                      DropdownMenuItem(
                          value: 'account', child: Text('Account')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
              onChanged: (v) => setState(() => _category = v ?? 'other'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ticket submitted successfully'),
                    backgroundColor: Colors.black87,
                  ),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('Submit Ticket'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DevicesScreen extends ConsumerWidget {
  const _DevicesScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Logged-in Devices')),
      body: FutureBuilder(
        future: supabase
            .from('device_sessions')
            .select('*')
            .eq('user_id', userId ?? '')
            .order('last_active', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonList();
          }
          final devices = snapshot.data as List? ?? [];

          if (devices.isEmpty) {
            return const Center(child: Text('No active devices'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(_getDeviceIcon(device['device_type'])),
                  title: Text(device['device_name'] ?? 'Unknown Device'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${device['os_version'] ?? ''} • ${device['app_version'] ?? ''}'),
                      Text(
                        'Last active: ${_formatDate(device['last_active'])}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                  trailing: device['is_current_session'] == true
                      ? const Chip(label: Text('Current'))
                      : IconButton(
                          icon: const Icon(Icons.logout, color: Colors.red),
                          onPressed: () async {
                            await supabase.from('device_sessions').update(
                                {'is_active': false}).eq('id', device['id']);
                          },
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getDeviceIcon(String? type) {
    switch (type) {
      case 'mobile':
        return Icons.phone_android;
      case 'tablet':
        return Icons.tablet_android;
      case 'desktop':
        return Icons.computer;
      case 'web':
        return Icons.web;
      default:
        return Icons.devices;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Never';
    try {
      return DateFormat('MMM dd, hh:mm a').format(DateTime.parse(date));
    } catch (e) {
      return 'Unknown';
    }
  }
}


/// Academic History Screen - Full academic transcript
class AcademicHistoryScreen extends ConsumerWidget {
  const AcademicHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: Future.wait([
          supabase
              .from('students')
              .select('*')
              .eq('profile_id', userId ?? '')
              .single(),
          supabase
              .from('student_grades')
              .select('*')
              .eq('student_id', userId ?? '')
              .order('exam_date', ascending: false),
          supabase
              .from('certificates')
              .select('*')
              .eq('student_id', userId ?? '')
              .eq('status', 'issued'),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonDetailPage();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          }

          final results = snapshot.data as List;
          final student = results[0] as Map<String, dynamic>?;
          final grades = results[1] as List? ?? [];
          final certificates = results[2] as List? ?? [];

          // Calculate statistics
          final totalCourses = grades.map((g) => g['subject']).toSet().length;
          final avgGrade = grades.isEmpty
              ? 0.0
              : grades.fold<double>(
                    0,
                    (sum, g) => sum + (g['percentage'] as num? ?? 0).toDouble(),
                  ) /
                  grades.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Info Card
                _StudentInfoCard(
                  student: student,
                  totalCourses: totalCourses,
                  avgGrade: avgGrade,
                  certificates: certificates.length,
                ).animate().fadeIn(duration: 600.ms),
                const SizedBox(height: 24),

                // Timeline
                const Text(
                  'Academic Timeline',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _TimelineSection(
                  title: 'Current Semester',
                  grades: grades.where((g) {
                    if (g['exam_date'] == null) return false;
                    try {
                      final date = DateTime.parse(g['exam_date']);
                      return date.isAfter(
                          DateTime.now().subtract(const Duration(days: 180)));
                    } catch (e) {
                      return false;
                    }
                  }).toList(),
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                const SizedBox(height: 16),

                _TimelineSection(
                  title: 'Previous Semester',
                  grades: grades.where((g) {
                    if (g['exam_date'] == null) return false;
                    try {
                      final date = DateTime.parse(g['exam_date']);
                      return date.isBefore(DateTime.now()
                              .subtract(const Duration(days: 180))) &&
                          date.isAfter(DateTime.now()
                              .subtract(const Duration(days: 365)));
                    } catch (e) {
                      return false;
                    }
                  }).toList(),
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

                if (certificates.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Certificates Earned',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...certificates
                      .map((cert) => _CertificateMiniCard(cert: cert)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Student Profile Screen
class StudentProfileScreen extends ConsumerStatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  ConsumerState<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadProfileData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? {};
          _nameController.text =
              data['full_name'] ?? metadata['full_name'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _addressController.text = data['address'] ?? '';
          _emergencyController.text =
              data['emergency_contact_phone'] ?? '';

          final name =
              _nameController.text.isNotEmpty ? _nameController.text : 'User';
          final email = user?.email ?? data['email'] ?? 'N/A';
          final role = data['role']?.toString().toUpperCase() ??
              (metadata['role']?.toString().toUpperCase() ?? 'STUDENT');
          final studentCode = data['student_code'] ?? 'N/A';
          final joined = _formatDate(data['created_at']);
          final status = data['status']?.toString().toUpperCase() ?? 'ACTIVE';
          final gender = data['gender']?.toString().toUpperCase() ??
              metadata['gender']?.toString().toUpperCase() ??
              'N/A';
          final dob = data['date_of_birth'] != null
              ? _formatDate(data['date_of_birth'])
              : 'N/A';
          final nationality =
              data['nationality'] ?? metadata['nationality'] ?? 'N/A';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(name,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(role,
                            style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text('Personal Information',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _InfoTile(
                    icon: Icons.person,
                    label: 'Full Name',
                    child: _buildEditableField(_nameController)),
                _InfoTile(
                    icon: Icons.phone,
                    label: 'Phone',
                    child: _buildEditableField(_phoneController,
                        keyboardType: TextInputType.phone)),
                _InfoTile(
                    icon: Icons.location_on,
                    label: 'Address',
                    child:
                        _buildEditableField(_addressController, maxLines: 2)),
                _InfoTile(
                    icon: Icons.emergency,
                    label: 'Emergency Phone',
                    child: _buildEditableField(_emergencyController,
                        keyboardType: TextInputType.phone)),
                const SizedBox(height: 24),
                Text('Account Information',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _InfoTile(icon: Icons.email, label: 'Email', value: email),
                _InfoTile(
                    icon: Icons.badge, label: 'Student ID', value: studentCode),
                _InfoTile(
                    icon: Icons.calendar_today, label: 'Joined', value: joined),
                _InfoTile(icon: Icons.circle, label: 'Status', value: status),
                const SizedBox(height: 24),
                Text('Additional Details',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _InfoTile(icon: Icons.wc, label: 'Gender', value: gender),
                _InfoTile(icon: Icons.cake, label: 'Date of Birth', value: dob),
                _InfoTile(
                    icon: Icons.flag, label: 'Nationality', value: nationality),
                _InfoTile(
                    icon: Icons.phone_android,
                    label: 'Auth Phone',
                    value: user?.phone ?? 'N/A'),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _updateProfile,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditableField(TextEditingController controller,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await supabase.from('users').update({
        'full_name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'emergency_contact_phone': _emergencyController.text,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.black87),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> _loadProfileData() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;
    try {
      return await supabase.from('users').select().eq('id', userId).single();
    } catch (e) {
      return null;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
    } catch (e) {
      return 'Invalid';
    }
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? child;

  const _InfoTile(
      {required this.icon, required this.label, this.value, this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(label,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600))),
          Expanded(
            child: child ??
                Text(value ?? 'N/A',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.7))),
          ),
        ],
      ),
    );
  }
}

/// Placement Test Screen
class PlacementTestScreen extends ConsumerStatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  ConsumerState<PlacementTestScreen> createState() =>
      _PlacementTestScreenState();
}

class _PlacementTestScreenState extends ConsumerState<PlacementTestScreen> {
  int _currentQuestion = 0;
  final Map<int, String> _answers = {};
  bool _isSubmitted = false;

  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    // No placement question table exists in the schema, so the
    // placement test uses this built-in question bank.
    _questions = [
      {
        'question': 'Choose the correct word: “She ___ to school every day.”',
        'options': ['go', 'goes', 'going', 'gone'],
        'correct_answer': 'goes',
      },
      {
        'question': 'Which sentence is grammatically correct?',
        'options': [
          'I have seen him yesterday.',
          'I saw him yesterday.',
          'I seen him yesterday.',
          'I did saw him yesterday.',
        ],
        'correct_answer': 'I saw him yesterday.',
      },
      {
        'question': 'The opposite of “difficult” is:',
        'options': ['hard', 'easy', 'tough', 'heavy'],
        'correct_answer': 'easy',
      },
      {
        'question': 'Choose the correct article: “He is ___ honest man.”',
        'options': ['a', 'an', 'the', 'no article'],
        'correct_answer': 'an',
      },
      {
        'question': 'Which word is a verb?',
        'options': ['beautiful', 'quickly', 'teach', 'happiness'],
        'correct_answer': 'teach',
      },
      {
        'question': '“I am interested ___ learning English.”',
        'options': ['at', 'in', 'on', 'for'],
        'correct_answer': 'in',
      },
    ];
    if (mounted) setState(() => _isLoading = false);
  }

  void _selectAnswer(String answer) {
    setState(() {
      _answers[_currentQuestion] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() => _currentQuestion++);
    } else {
      setState(() => _isSubmitted = true);
      _savePlacementTestResult();
    }
  }

  Future<void> _savePlacementTestResult() async {
    int correctCount = 0;
    for (int i = 0; i < _questions.length; i++) {
      final selectedAnswer = _answers[i];
      final correctAnswer = _questions[i]['correct_answer'];
      if (selectedAnswer != null && selectedAnswer == correctAnswer) {
        correctCount++;
      }
    }
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      // Persist the result on the student's real record.
      final studentRows = await supabase
          .from('students')
          .select('id')
          .eq('profile_id', userId ?? '')
          .limit(1);
      if (studentRows.isNotEmpty) {
        final percentage = _questions.isEmpty
            ? 0
            : (correctCount / _questions.length * 100).round();
        await supabase.from('students').update({
          'placement_test_score': percentage,
          'placement_test_date': DateTime.now().toIso8601String(),
        }).eq('id', studentRows.first['id']);
      }
    } catch (_) {}
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      setState(() => _currentQuestion--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Placement Test'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isSubmitted
              ? _buildResults()
              : _buildTest(),
    );
  }

  Widget _buildTest() {
    final question = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(Colors.black87),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            'Question ${_currentQuestion + 1} of ${_questions.length}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 32),

          // Question
          Text(
            question['question'],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),

          // Options
          ...(question['options'] as List).map((option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _OptionTile(
                  label: option,
                  isSelected: _answers[_currentQuestion] == option,
                  onTap: () => _selectAnswer(option),
                ),
              )),

          const Spacer(),

          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentQuestion > 0)
                OutlinedButton.icon(
                  onPressed: _previousQuestion,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                )
              else
                const SizedBox.shrink(),
              FilledButton.icon(
                onPressed:
                    _answers[_currentQuestion] == null ? null : _nextQuestion,
                icon: Icon(_currentQuestion == _questions.length - 1
                    ? Icons.check
                    : Icons.arrow_forward),
                label: Text(_currentQuestion == _questions.length - 1
                    ? 'Submit'
                    : 'Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.black87,
            size: 80,
          ).animate().scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 600.ms),
          const SizedBox(height: 24),
          const Text(
            'Test Completed!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Your recommended level: Intermediate',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.school, color: Colors.black87, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'Based on your answers, we recommend:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'B1 Intermediate English',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.home),
            label: const Text('Back to Dashboard'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widgets
class _StudentInfoCard extends StatelessWidget {
  final Map<String, dynamic>? student;
  final int totalCourses;
  final double avgGrade;
  final int certificates;

  const _StudentInfoCard({
    required this.student,
    required this.totalCourses,
    required this.avgGrade,
    required this.certificates,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade700, Colors.grey.shade900],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(
                  (student?['full_name']?[0] ?? 'S').toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student?['full_name'] ?? 'Student',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      student?['student_code'] ?? 'ID: N/A',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatItem(label: 'Courses', value: totalCourses.toString()),
              _StatItem(
                  label: 'Avg Grade', value: '${avgGrade.toStringAsFixed(1)}%'),
              _StatItem(label: 'Certificates', value: certificates.toString()),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  final String title;
  final List grades;

  const _TimelineSection({required this.title, required this.grades});

  @override
  Widget build(BuildContext context) {
    if (grades.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('No records for this period',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...grades.map((g) => _GradeTimelineItem(grade: g)),
      ],
    );
  }
}

class _GradeTimelineItem extends StatelessWidget {
  final Map<String, dynamic> grade;
  const _GradeTimelineItem({required this.grade});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: (grade['percentage'] as num? ?? 0) >= 75
                  ? Colors.black87
                  : Colors.orange,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grade['subject'] ?? 'Subject',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  _formatDate(grade['exam_date']),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            '${(grade['percentage'] as num? ?? 0).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: (grade['percentage'] as num? ?? 0) >= 75
                  ? Colors.black87
                  : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(dynamic date) {
    if (date == null) return 'No date';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
    } catch (e) {
      return 'Invalid';
    }
  }
}

class _CertificateMiniCard extends StatelessWidget {
  final Map<String, dynamic> cert;
  const _CertificateMiniCard({required this.cert});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.card_membership, color: Colors.amber.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              cert['course_name'] ?? 'Certificate',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            _formatDate(cert['issue_date']),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  static String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('MMM yyyy').format(DateTime.parse(date));
    } catch (e) {
      return 'Invalid';
    }
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade200 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black87 : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.black87, size: 16)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.grey.shade800 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Exams Screen - View all exams
class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Exams'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PaginatedListView<Map<String, dynamic>>(
        fetcher: (page, pageSize) async {
          final data = await supabase
              .from('exams')
              .select('*, classes(*), programs(*)')
              .order('exam_date', ascending: true)
              .range(page * pageSize, page * pageSize + pageSize - 1);
          return List<Map<String, dynamic>>.from(data);
        },
        skeleton: (context) => const SkeletonListPage(itemCount: 8),
        empty: (context, _) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz_rounded, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No exams scheduled',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
        itemBuilder: (context, exam, index) {
          final examDate = exam['exam_date'] != null
              ? DateTime.parse(exam['exam_date'])
              : null;
          final isUpcoming = examDate?.isAfter(DateTime.now()) ?? false;

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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isUpcoming
                              ? Colors.grey.shade300
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.quiz_rounded,
                          color: isUpcoming ? Colors.black87 : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exam['name'] ?? 'Untitled Exam',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              exam['subject'] ?? 'General',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(exam['status']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          exam['status']?.toString().toUpperCase() ??
                              'SCHEDULED',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ExamInfoChip(Icons.calendar_today,
                          _formatDate(exam['exam_date'])),
                      const SizedBox(width: 8),
                      _ExamInfoChip(Icons.access_time,
                          '${exam['duration_minutes'] ?? 60} min'),
                      const SizedBox(width: 8),
                      _ExamInfoChip(Icons.stars,
                          '${exam['total_marks'] ?? 100} marks'),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (100 * index).ms, duration: 400.ms);
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'scheduled':
        return Colors.black87;
      case 'completed':
        return Colors.black87;
      case 'cancelled':
        return Colors.red;
      case 'in_progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'No date';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}

/// Results Screen - Detailed exam results
class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Results'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PaginatedListView<Map<String, dynamic>>(
        fetcher: (page, pageSize) async {
          final data = await supabase
              .from('exam_results')
              .select('*')
              .eq('student_id', userId ?? '')
              .order('exam_date', ascending: false)
              .range(page * pageSize, page * pageSize + pageSize - 1);
          return List<Map<String, dynamic>>.from(data);
        },
        skeleton: (context) => const SkeletonListPage(itemCount: 8),
        empty: (context, _) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assessment_rounded, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No results available',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
        itemBuilder: (context, result, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          result['exam_name'] ?? 'Exam',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${(result['percentage'] as num? ?? 0).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              (result['percentage'] as num? ?? 0) >= 75
                                  ? Colors.black87
                                  : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result['subject'] ?? 'General',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ExamInfoChip(Icons.score,
                          '${result['score']}/${result['max_score']}'),
                      const SizedBox(width: 8),
                      _ExamInfoChip(Icons.grade, result['grade'] ?? '-'),
                      const SizedBox(width: 8),
                      _ExamInfoChip(Icons.calendar_today,
                          _formatDate(result['exam_date'])),
                    ],
                  ),
                  if (result['comments'] != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        result['comments'],
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'No date';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return 'Invalid';
    }
  }
}

/// Certificates Screen - View and download certificates
class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Certificates'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PaginatedListView<Map<String, dynamic>>(
        fetcher: (page, pageSize) async {
          final data = await supabase
              .from('certificates')
              .select('*')
              .eq('student_id', userId ?? '')
              .eq('status', 'issued')
              .order('issue_date', ascending: false)
              .range(page * pageSize, page * pageSize + pageSize - 1);
          return List<Map<String, dynamic>>.from(data);
        },
        skeleton: (context) => const SkeletonListPage(itemCount: 8),
        empty: (context, _) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.card_membership_rounded,
                  size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No certificates yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
              SizedBox(height: 8),
              Text(
                'Complete courses to earn certificates',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        itemBuilder: (context, cert, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _showCertificateDetail(context, cert),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade400,
                            Colors.amber.shade700
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.card_membership,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cert['certificate_type']?.toString().toUpperCase() ??
                                'CERTIFICATE',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cert['course_name'] ?? 'Course Certificate',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Issued: ${_formatDate(cert['issue_date'])}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: (100 * index).ms, duration: 400.ms);
        },
      ),
    );
  }

  void _showCertificateDetail(BuildContext context, Map<String, dynamic> cert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.amber.shade700],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.card_membership,
                color: Colors.white,
                size: 64,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              cert['certificate_type']?.toString().toUpperCase() ??
                  'CERTIFICATE',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cert['course_name'] ?? 'Course Certificate',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _ExamDetailRow(
                label: 'Certificate No',
                value: cert['certificate_number'] ?? '-'),
            _ExamDetailRow(
                label: 'Issue Date', value: _formatDate(cert['issue_date'])),
            if (cert['level_achieved'] != null)
              _ExamDetailRow(label: 'Level', value: cert['level_achieved']),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Download logic
              },
              icon: const Icon(Icons.download),
              label: const Text('Download Certificate'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return 'Invalid';
    }
  }
}

// Helper Widgets
class _ExamInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ExamInfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}

class _ExamDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _ExamDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}


class AttendanceScreenRealtime extends ConsumerStatefulWidget {
  const AttendanceScreenRealtime({super.key});

  @override
  ConsumerState<AttendanceScreenRealtime> createState() =>
      _AttendanceScreenRealtimeState();
}

class _AttendanceScreenRealtimeState
    extends ConsumerState<AttendanceScreenRealtime> {
  String selectedMonth = 'All';

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(attendanceStreamProvider);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Attendance Overview',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: attendanceAsync.when(
              data: (attendanceList) {
                if (attendanceList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No attendance records',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final totalDays = attendanceList.length;
                final presentDays = attendanceList
                    .where((a) => a.status == AttendanceStatus.present)
                    .length;
                final attendancePercentage =
                    totalDays > 0 ? (presentDays / totalDays * 100) : 0.0;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: _getAttendanceColor(attendancePercentage)
                          .withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.pie_chart_outline,
                              size: 64,
                              color: _getAttendanceColor(attendancePercentage),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${attendancePercentage.toStringAsFixed(1)}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _getAttendanceColor(
                                      attendancePercentage,
                                    ),
                                  ),
                            ),
                            Text(
                              'Overall Attendance',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatColumn(
                                  'Present',
                                  presentDays,
                                  Colors.black87,
                                ),
                                _buildStatColumn(
                                  'Absent',
                                  totalDays - presentDays,
                                  Colors.red,
                                ),
                                _buildStatColumn(
                                  'Total Days',
                                  totalDays,
                                  Colors.black87,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Recent Records',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...attendanceList.take(10).map(
                          (record) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _getStatusBackgroundColor(
                                    record.status,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getStatusIcon(record.status),
                                  color: _getStatusForegroundColor(
                                    record.status,
                                  ),
                                ),
                              ),
                              title: Text(_formatDate(record.date)),
                              subtitle: Text(
                                '${record.classId} | ${record.notes ?? 'No notes'}',
                              ),
                              trailing: Chip(
                                label: Text(
                                  _formatStatus(record.status),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: _getStatusForegroundColor(
                                  record.status,
                                ),
                              ),
                            ),
                          ),
                        ),
                  ],
                );
              },
              loading: () => const SkeletonListPage(itemCount: 8),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(attendanceStreamProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage < 50) return Colors.red;
    if (percentage < 75) return Colors.orange;
    if (percentage < 90) return Colors.black87;
    return Colors.black87;
  }

  Color _getStatusBackgroundColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.grey.shade300;
      case AttendanceStatus.absent:
        return Colors.red.shade100;
      case AttendanceStatus.late:
      case AttendanceStatus.leave:
        return Colors.orange.shade100;
    }
  }

  Color _getStatusForegroundColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.grey.shade800;
      case AttendanceStatus.absent:
        return Colors.red.shade700;
      case AttendanceStatus.late:
      case AttendanceStatus.leave:
        return Colors.orange.shade700;
    }
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.late:
        return Icons.access_time;
      case AttendanceStatus.leave:
        return Icons.event_busy;
    }
  }

  String _formatStatus(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.leave:
        return 'Leave';
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Widget _buildStatColumn(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}


class GradesScreenRealtime extends ConsumerStatefulWidget {
  const GradesScreenRealtime({super.key});

  @override
  ConsumerState<GradesScreenRealtime> createState() =>
      _GradesScreenRealtimeState();
}

class _GradesScreenRealtimeState extends ConsumerState<GradesScreenRealtime> {
  String searchQuery = '';
  String? selectedTerm;

  @override
  Widget build(BuildContext context) {
    final gradesAsync = ref.watch(gradesStreamProvider);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search grades...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          Expanded(
            child: gradesAsync.when(
              data: (grades) {
                var filtered = grades.where((g) {
                  final subject = g['subject']?.toString().toLowerCase() ?? '';
                  final exam = g['exam_name']?.toString().toLowerCase() ?? '';
                  final matchesSearch =
                      subject.contains(searchQuery.toLowerCase()) ||
                          exam.contains(searchQuery.toLowerCase());
                  final matchesTerm =
                      selectedTerm == null || g['term'] == selectedTerm;
                  return matchesSearch && matchesTerm;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.grade_outlined,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No grades found',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600])),
                      ],
                    ),
                  );
                }

                // Calculate GPA
                final totalPercentage = filtered.fold<double>(
                    0.0, (sum, g) => sum + (g['percentage'] ?? 0.0));
                final avgPercentage = filtered.isNotEmpty
                    ? totalPercentage / filtered.length
                    : 0.0;
                final gpa = (avgPercentage / 25).clamp(0.0, 4.0);

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: Colors.grey[200],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('GPA',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 14)),
                                Text(gpa.toStringAsFixed(2),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.bold,
                                        )),
                              ],
                            ),
                            Column(
                              children: [
                                Text('Average',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 14)),
                                Text('${avgPercentage.toStringAsFixed(1)}%',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.bold,
                                        )),
                              ],
                            ),
                            Column(
                              children: [
                                Text('Courses',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 14)),
                                Text('${filtered.length}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.bold,
                                        )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...filtered
                        .map((grade) => Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      _getGradeColor(grade['grade'])
                                          .withValues(alpha: 0.1),
                                  child: Text(
                                    grade['grade']?.toString() ?? 'N/A',
                                    style: TextStyle(
                                      color: _getGradeColor(grade['grade']),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                title: Text(
                                    grade['subject']?.toString() ?? 'Unknown'),
                                subtitle: Text(
                                    '${grade['exam_name']} • ${grade['term']}'),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        '${grade['score']}/${grade['total_marks']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text('${grade['percentage']}%',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                            )),
                    ],
                );
              },
              loading: () => const SkeletonListPage(itemCount: 8),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(gradesStreamProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(dynamic grade) {
    switch (grade.toString().toUpperCase()) {
      case 'A':
      case 'A+':
        return Colors.black87;
      case 'B':
        return Colors.black87;
      case 'C':
        return Colors.orange;
      case 'D':
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}


class ResourcesScreenRealtime extends ConsumerStatefulWidget {
  const ResourcesScreenRealtime({super.key});

  @override
  ConsumerState<ResourcesScreenRealtime> createState() =>
      _ResourcesScreenRealtimeState();
}

class _ResourcesScreenRealtimeState
    extends ConsumerState<ResourcesScreenRealtime> {
  String searchQuery = '';
  String filterType = 'All';

  @override
  Widget build(BuildContext context) {
    final resourcesAsync = ref.watch(resourcesStreamProvider);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search resources...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          Expanded(
            child: resourcesAsync.when(
              data: (resourcesList) {
                var filtered = resourcesList.where((r) {
                  final title = r['title']?.toString().toLowerCase() ?? '';
                  final matchesSearch =
                      title.contains(searchQuery.toLowerCase());
                  final matchesFilter =
                      filterType == 'All' || r['type'] == filterType;
                  return matchesSearch && matchesFilter;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_outlined,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No resources found',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600])),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final resource = filtered[index];

                    return Card(
                      child: InkWell(
                        onTap: () => _showDetails(resource),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: _getTypeColor(resource['type'])
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getTypeIcon(resource['type']),
                                  size: 32,
                                  color: _getTypeColor(resource['type']),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                resource['title']?.toString() ?? 'Untitled',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                resource['subject']?.toString() ?? '',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(Icons.download,
                                      size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text('${resource['downloads'] ?? 0}',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                  const Spacer(),
                                  Icon(Icons.visibility,
                                      size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text('${resource['views'] ?? 0}',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const SkeletonGridPage(itemCount: 8),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(resourcesStreamProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(dynamic type) {
    switch (type.toString().toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'video':
        return Colors.black87;
      case 'image':
        return Colors.black87;
      case 'document':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(dynamic type) {
    switch (type.toString().toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'video':
        return Icons.videocam;
      case 'image':
        return Icons.image;
      case 'document':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _showDetails(Map<String, dynamic> resource) {
    showModalBottomSheet(
      context: context,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getTypeColor(resource['type']).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTypeIcon(resource['type']),
                      size: 32,
                      color: _getTypeColor(resource['type']),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource['title']?.toString() ?? 'Untitled',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${resource['subject']} • ${resource['type']}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              _buildDetailRow('Uploaded', _formatDate(resource['created_at'])),
              _buildDetailRow(
                  'Size', resource['size']?.toString() ?? 'Unknown'),
              _buildDetailRow('Downloads', '${resource['downloads'] ?? 0}'),
              _buildDetailRow('Views', '${resource['views'] ?? 0}'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Download resource feature')),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Download'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
              width: 100,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    DateTime dt;
    if (date is String) {
      dt = DateTime.parse(date);
    } else if (date is DateTime) {
      dt = date;
    } else {
      return 'Unknown';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}


class ScheduleScreenRealtime extends ConsumerStatefulWidget {
  const ScheduleScreenRealtime({super.key});

  @override
  ConsumerState<ScheduleScreenRealtime> createState() =>
      _ScheduleScreenRealtimeState();
}

class _ScheduleScreenRealtimeState
    extends ConsumerState<ScheduleScreenRealtime> {
  String selectedDay = 'Monday';
  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(scheduleStreamProvider);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: daysOfWeek.map((day) {
                  final isSelected = day == selectedDay;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(day.substring(0, 3)),
                      selected: isSelected,
                      onSelected: (selected) =>
                          setState(() => selectedDay = day),
                      backgroundColor: Colors.grey[200],
                      selectedColor: Colors.grey[400],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: scheduleAsync.when(
              data: (scheduleList) {
                var filtered = scheduleList
                    .where((s) => s['day_of_week'] == selectedDay)
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.schedule_outlined,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No classes scheduled',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Text('Enjoy your free day!',
                            style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                // Sort by time
                filtered.sort((a, b) =>
                    (a['start_time'] ?? '').compareTo(b['start_time'] ?? ''));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _showDetails(item),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['subject']?.toString() ?? 'Unknown',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                        '${item['start_time']} - ${item['end_time']}'),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.person,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(item['teacher']?.toString() ??
                                            'TBD'),
                                        const SizedBox(width: 16),
                                        Icon(Icons.place,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(item['room']?.toString() ?? 'TBD'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: Colors.grey[400]),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const SkeletonListPage(itemCount: 8),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(scheduleStreamProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['subject']?.toString() ?? 'Unknown',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Day', item['day_of_week']?.toString() ?? 'N/A'),
              _buildDetailRow(
                  'Time', '${item['start_time']} - ${item['end_time']}'),
              _buildDetailRow('Room', item['room']?.toString() ?? 'TBD'),
              _buildDetailRow('Teacher', item['teacher']?.toString() ?? 'TBD'),
              _buildDetailRow('Type', item['type']?.toString() ?? 'Lecture'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
              width: 100,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}


class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonGridPage();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final courses = snapshot.data ?? [];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: courses.map((course) {
                    final total = course['totalLessons'] as int? ?? 0;
                    final completed = course['completedLessons'] as int? ?? 0;
                    final progress =
                        total > 0 ? (completed / total * 100).round() : 0;
                    return Card(
                      elevation: 3,
                      child: InkWell(
                        onTap: () => _showCourseDetails(course),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.1),
                                child: Icon(Icons.school,
                                    color: Theme.of(context).primaryColor),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                course['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                course['instructor'],
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$progress%',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '$completed/$total',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: progress / 100,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).primaryColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchCourses() async {
    final supabase = Supabase.instance.client;
    final response =
        await supabase.from('courses').select().eq('status', 'active');
    return List<Map<String, dynamic>>.from(response);
  }

  void _showCourseDetails(Map<String, dynamic> course) {
    final total = course['totalLessons'] as int? ?? 0;
    final completed = course['completedLessons'] as int? ?? 0;
    final progress = total > 0 ? (completed / total * 100).round() : 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course['name'],
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Instructor', course['instructor']),
              _buildDetailRow('Progress', '$progress%'),
              _buildDetailRow('Lessons', '$completed/$total completed'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    final supabase = Supabase.instance.client;
                    // Resolve the student record for this user.
                    final studentRows = await supabase
                        .from('students')
                        .select('id')
                        .eq('profile_id',
                            supabase.auth.currentUser?.id ?? '')
                        .limit(1);
                    final studentId =
                        (studentRows.isNotEmpty
                                ? studentRows.first['id']
                                : null)
                            as String?;
                    final subjectName = course['name']?.toString() ??
                        course['title']?.toString() ??
                        'General';
                    if (studentId != null) {
                      final existing = await supabase
                          .from('student_progress')
                          .select('id')
                          .eq('student_id', studentId)
                          .eq('subject', subjectName)
                          .limit(1);
                      if ((existing as List).isNotEmpty) {
                        await supabase
                            .from('student_progress')
                            .update({'updated_at': DateTime.now()
                                .toIso8601String()})
                            .eq('id', existing.first['id']);
                      } else {
                        await supabase.from('student_progress').insert({
                          'student_id': studentId,
                          'subject': subjectName,
                          'updated_at':
                              DateTime.now().toIso8601String(),
                        });
                      }
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Progress saved!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Continue Learning'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
              width: 100,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}


class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAssignments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonListPage(itemCount: 6);
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final assignments = snapshot.data ?? [];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search assignments...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = assignments[index];
                    final subject = assignment['courses'] is Map
                        ? (assignment['courses']['name'] ?? '')
                        : (assignment['subject'] ?? '');
                    final dueDate = assignment['due_date'] != null
                        ? DateTime.parse(assignment['due_date'])
                        : DateTime.now();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getStatusColor(assignment['status'])
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            assignment['status'] == 'Submitted'
                                ? Icons.check_circle
                                : Icons.assignment,
                            color: _getStatusColor(assignment['status']),
                          ),
                        ),
                        title: Text(assignment['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$subject • ${assignment['score'] ?? 0} points'),
                            Text('Due: ${_formatDate(dueDate)}'),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(assignment['status'])
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            assignment['status'],
                            style: TextStyle(
                              color: _getStatusColor(assignment['status']),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        onTap: () => _showAssignmentDetails(assignment),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAssignments() async {
    final supabase = Supabase.instance.client;
    // Resolve this user's student record first.
    final studentRows = await supabase
        .from('students')
        .select('id')
        .eq('profile_id', supabase.auth.currentUser?.id ?? '')
        .limit(1);
    final studentId =
        (studentRows.isNotEmpty ? studentRows.first['id'] : null) as String?;
    if (studentId == null) return [];
    final response = await supabase
        .from('student_assignments')
        .select('*, courses(name)')
        .eq('student_id', studentId)
        .order('due_date');
    return List<Map<String, dynamic>>.from(response).map((a) {
      final rawStatus = a['status']?.toString() ?? 'pending';
      return {
        ...a,
        'status': rawStatus.isEmpty
            ? 'Pending'
            : rawStatus[0].toUpperCase() + rawStatus.substring(1),
      };
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.black87;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    if (diff < 0) return '${-diff} days overdue';
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return 'In $diff days';
  }

  void _showAssignmentDetails(Map<String, dynamic> assignment) {
    final subject = assignment['courses'] is Map
        ? (assignment['courses']['name'] ?? '')
        : (assignment['subject'] ?? '');
    final dueDate = assignment['due_date'] != null
        ? DateTime.parse(assignment['due_date'])
        : DateTime.now();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                assignment['title'],
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Subject', subject),
              _buildDetailRow('Points', '${assignment['score'] ?? 0}'),
              _buildDetailRow('Due Date', _formatDate(dueDate)),
              _buildDetailRow('Status', assignment['status']),
              const SizedBox(height: 24),
              if (assignment['status'] == 'Pending')
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await Supabase.instance.client
                          .from('student_assignments')
                          .update({
                            'status': 'submitted',
                            'submitted_at': DateTime.now().toIso8601String(),
                          })
                          .eq('id', assignment['id']);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Assignment submitted successfully!')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Submit Assignment'),
                )
              else if (assignment['status'] == 'Submitted')
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'View submission feature (mock implementation)')),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Submission'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
              width: 100,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// Shared helpers restored after lifestyle-screen conversion
class _CourseInfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;
  const _CourseInfoSection({required this.title, required this.icon, required this.content});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(leading: Icon(icon), title: Text(title), subtitle: Text(content)),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final String title;
  final int lessons;
  final String duration;
  final bool completed;
  const _ModuleTile({required this.title, required this.lessons, required this.duration, required this.completed});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(completed ? Icons.check_circle : Icons.play_circle_outline, color: completed ? Colors.green : null),
      title: Text(title),
      subtitle: Text('$lessons lesson(s) · $duration'),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        Expanded(child: Text(value)),
      ]),
    );
  }
}

class _SubjectProgressCard extends StatelessWidget {
  final String subject;
  final int progress;
  final String grade;
  final Color color;
  const _SubjectProgressCard({required this.subject, required this.progress, required this.grade, required this.color});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            Text(grade, style: TextStyle(color: color)),
          ]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: (progress.clamp(0, 100)) / 100),
          const SizedBox(height: 4),
          Text('$progress%'),
        ]),
      ),
    );
  }
}

class _StudyTaskTile extends StatelessWidget {
  final String title;
  final String subject;
  final String time;
  final String priority;
  const _StudyTaskTile({required this.title, required this.subject, required this.time, required this.priority});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.task_alt),
      title: Text(title),
      subtitle: Text('$subject · $time'),
      trailing: Text(priority),
    );
  }
}

