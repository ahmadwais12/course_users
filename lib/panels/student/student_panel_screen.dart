import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:course_users/widgets/base_panel_layout.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:course_users/widgets/insight_ui.dart';
import 'package:course_users/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:course_users/providers/panel_stats_provider.dart';
import 'package:course_users/components/components.dart';
import 'package:course_users/l10n/app_localizations.dart';
import 'package:course_users/l10n/locale_keys.dart';
import 'package:course_users/widgets/ad_banner_widget.dart';

class StudentPanelScreen extends ConsumerWidget {
  const StudentPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentStatsAsync = ref.watch(studentStatsProvider);
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    final locale = ref.watch(localeProvider);

    return BasePanelLayout(
      title: AppLocalizations.translate(LStudentPanel.title, locale),
      children: [
        // Hero Card
        studentStatsAsync
            .when(
              data: (stats) {
                return InsightHeroCard(
                  eyebrow: AppLocalizations.translate(LStudentPanel.eyebrow, locale),
                  title: AppLocalizations.translate(LStudentPanel.welcome, locale),
                  subtitle: AppLocalizations.translate(LStudentPanel.subtitle, locale),
                  accent: Colors.black87,
                  chips: [
                    InsightStatChip(
                        label: AppLocalizations.translate(LStudentPanel.courses, locale), value: stats.totalCourses.toString()),
                    InsightStatChip(
                        label: AppLocalizations.translate(LStudentPanel.assignments, locale),
                        value: stats.totalAssignments.toString()),
                    InsightStatChip(
                        label: AppLocalizations.translate(LStudentPanel.grades, locale), value: stats.totalGrades.toString()),
                  ],
                  actions: [
                    _GradientButton(
                      onPressed: () => context.go('/grades-detail'),
                      icon: Icons.grade_rounded,
                      label: AppLocalizations.translate(LStudentPanel.viewGrades, locale),
                      gradient: AppGradients.skyCyanHorizontal,
                    ),
                    _GradientButton(
                      onPressed: () => context.go('/assignments'),
                      icon: Icons.assignment_rounded,
                      label: AppLocalizations.translate(LStudentPanel.assignments, locale),
                      gradient: AppGradients.blueHorizontal,
                      isOutlined: true,
                    ),
                  ],
                );
              },
              loading: () => const SkeletonDashboard(),
              error: (_, __) => const SizedBox.shrink(),
            )
            .animate()
            .fadeIn(duration: 800.ms)
            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
        const SizedBox(height: 24),

        // Section: Current Grades Table
        FutureBuilder(
          future: () async {
            final studentRows = await supabase
                .from('students')
                .select('id')
                .eq('profile_id', userId ?? '')
                .limit(1);
            final studentId = studentRows.isNotEmpty
                ? studentRows.first['id']
                : null;
            if (studentId == null) return <Map<String, dynamic>>[];
            final data = await supabase
                .from('student_grades')
                .select()
                .eq('student_id', studentId)
                .order('exam_date', ascending: false)
                .limit(5);
            return (data as List).cast<Map<String, dynamic>>();
          }(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SkeletonDashboard();
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const SizedBox.shrink();
            }
            final grades = snapshot.data as List;
            final rows = grades.map((g) {
              return [
                g['subject'] as String? ?? AppLocalizations.translate(LStudentPanel.unknown, locale),
                AppLocalizations.translate(LStudentPanel.teacher, locale),
                '${(g['percentage'] as num? ?? 0).toStringAsFixed(0)}%',
                g['grade'] as String? ?? '-',
                _getGradeStatus(g['grade'] as String?, locale),
              ];
            }).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InsightSectionTitle(
                  title: AppLocalizations.translate(LStudentPanel.currentGrades, locale),
                  subtitle: AppLocalizations.translate(LStudentPanel.gradesSubtitle, locale),
                  trailing: TextButton.icon(
                    onPressed: () => context.go('/grades-detail'),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(AppLocalizations.translate(LStudentPanel.details, locale)),
                  ),
                ),
                const SizedBox(height: 12),
                InsightTableCard(
                  title: '',
                  subtitle: '',
                  columns: [
                    AppLocalizations.translate(LStudentPanel.subjectCol, locale),
                    AppLocalizations.translate(LStudentPanel.teacher, locale),
                    AppLocalizations.translate(LStudentPanel.scoreCol, locale),
                    AppLocalizations.translate(LStudentPanel.gradeCol, locale),
                    AppLocalizations.translate(LStudentPanel.statusCol, locale)
                  ],
                  rows: rows.isEmpty
                      ? [
                          [AppLocalizations.translate(LStudentPanel.noGrades, locale), '-', '-', '-', '-']
                        ]
                      : rows,
                ),
              ],
            );
          },
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
        const SizedBox(height: 24),

        // Section: Analytics Charts
        InsightSectionTitle(
          title: AppLocalizations.translate(LStudentPanel.performanceAnalytics, locale),
          subtitle: AppLocalizations.translate(LStudentPanel.analyticsSubtitle, locale),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Line Chart: Grade Trend
            Expanded(
              child: InsightLineChartCard(
                title: AppLocalizations.translate(LStudentPanel.gradeTrend, locale),
                subtitle: AppLocalizations.translate(LStudentPanel.last6Months, locale),
                accent: Colors.black87,
                points: const [
                  InsightPoint('Aug', 78),
                  InsightPoint('Sep', 82),
                  InsightPoint('Oct', 85),
                  InsightPoint('Nov', 84),
                  InsightPoint('Dec', 89),
                  InsightPoint('Jan', 92),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Segments: Assignment Status
            Expanded(
              child: InsightSegmentsCard(
                title: AppLocalizations.translate(LStudentPanel.assignmentStatus, locale),
                subtitle: AppLocalizations.translate(LStudentPanel.statusSubtitle, locale),
                segments: [
                  InsightSegment(
                      label: AppLocalizations.translate(LStudentPanel.completed, locale), value: 45, color: Colors.black87),
                  InsightSegment(
                      label: AppLocalizations.translate(LStudentPanel.pending, locale), value: 30, color: Colors.orange),
                  InsightSegment(label: AppLocalizations.translate(LStudentPanel.late, locale), value: 15, color: Colors.red),
                  InsightSegment(
                      label: AppLocalizations.translate(LStudentPanel.submitted, locale), value: 10, color: Colors.black87),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
        const SizedBox(height: 24),

        // Section: Study Process
        InsightSectionTitle(
          title: AppLocalizations.translate(LStudentPanel.assignmentWorkflow, locale),
          subtitle: AppLocalizations.translate(LStudentPanel.workflowSubtitle, locale),
        ),
        const SizedBox(height: 12),
        InsightProcessDiagram(
          title: '',
          subtitle: '',
          accent: Colors.purple,
          steps: [
            InsightFlowStep(
              title: AppLocalizations.translate(LStudentPanel.review, locale),
              subtitle: AppLocalizations.translate(LStudentPanel.reviewSub, locale),
              icon: Icons.visibility_rounded,
            ),
            InsightFlowStep(
              title: AppLocalizations.translate(LStudentPanel.research, locale),
              subtitle: AppLocalizations.translate(LStudentPanel.researchSub, locale),
              icon: Icons.search_rounded,
            ),
            InsightFlowStep(
              title: AppLocalizations.translate(LStudentPanel.complete, locale),
              subtitle: AppLocalizations.translate(LStudentPanel.completeSub, locale),
              icon: Icons.edit_rounded,
            ),
            InsightFlowStep(
              title: AppLocalizations.translate(LStudentPanel.submit, locale),
              subtitle: AppLocalizations.translate(LStudentPanel.submitSub, locale),
              icon: Icons.upload_file_rounded,
            ),
          ],
        ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
        const SizedBox(height: 24),

        // Section: Metric Cards
        studentStatsAsync
            .when(
              data: (stats) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InsightSectionTitle(
                      title: AppLocalizations.translate(LStudentPanel.quickStats, locale),
                      subtitle: AppLocalizations.translate(LStudentPanel.statsSubtitle, locale),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InsightMetricCard(
                            label: AppLocalizations.translate(LStudentPanel.activeCourses, locale),
                            value: stats.totalCourses.toString(),
                            trend: AppLocalizations.translate(LStudentPanel.thisSemester, locale),
                            icon: Icons.book_rounded,
                            accent: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InsightMetricCard(
                            label: AppLocalizations.translate(LStudentPanel.pendingAssignments, locale),
                            value: stats.pendingAssignments.toString(),
                            trend: AppLocalizations.translate(LStudentPanel.needAttention, locale),
                            icon: Icons.assignment_late_rounded,
                            accent: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InsightMetricCard(
                            label: AppLocalizations.translate(LStudentPanel.totalGrades, locale),
                            value: stats.totalGrades.toString(),
                            trend: AppLocalizations.translate(LStudentPanel.recorded, locale),
                            icon: Icons.grade_rounded,
                            accent: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const SkeletonDashboard(),
              error: (_, __) => const SizedBox.shrink(),
            )
            .animate()
            .fadeIn(delay: 500.ms, duration: 600.ms),
        const SizedBox(height: 24),

        // Section: Student Modules
        PanelSectionTitle(title: AppLocalizations.translate(LStudentPanel.studentModules, locale)),
        PanelActionGrid(
          actions: [
            (
              AppLocalizations.translate(LStudentPanel.mySchedule, locale),
              Icons.calendar_today_rounded,
              Colors.black87,
              () => context.go('/student-timetable')
            ),
            (
              AppLocalizations.translate(LStudentPanel.courses, locale),
              Icons.book_rounded,
              Colors.black87,
              () => context.go('/courses')
            ),
            (
              AppLocalizations.translate(LStudentPanel.grades, locale),
              Icons.grade_rounded,
              Colors.orange,
              () => context.go('/grades')
            ),
            (
              AppLocalizations.translate(LStudentPanel.exams, locale),
              Icons.quiz_rounded,
              Colors.red,
              () => context.go('/exams')
            ),
            (
              AppLocalizations.translate(LStudentPanel.results, locale),
              Icons.assessment_rounded,
              Colors.black87,
              () => context.go('/results')
            ),
            (
              AppLocalizations.translate(LStudentPanel.assignments, locale),
              Icons.assignment_rounded,
              Colors.black87,
              () => context.go('/assignments')
            ),
            (
              AppLocalizations.translate(LStudentPanel.attendance, locale),
              Icons.check_circle_rounded,
              Colors.cyan,
              () => context.go('/student-attendance')
            ),
            (
              AppLocalizations.translate(LStudentPanel.resources, locale),
              Icons.folder_rounded,
              Colors.brown,
              () => context.go('/student-resources')
            ),
            (
              AppLocalizations.translate(LStudentPanel.certificates, locale),
              Icons.card_membership_rounded,
              Colors.amber,
              () => context.go('/certificates')
            ),
            (
              AppLocalizations.translate(LStudentPanel.feeDetails, locale),
              Icons.payments_rounded,
              Colors.purple,
              () => context.go('/fee-details')
            ),
            (
              AppLocalizations.translate(LStudentPanel.library, locale),
              Icons.library_books_rounded,
              Colors.grey,
              () => context.go('/library')
            ),
            (
              AppLocalizations.translate(LStudentPanel.achievements, locale),
              Icons.emoji_events_rounded,
              Colors.deepOrange,
              () => context.go('/achievements')
            ),
            (
              AppLocalizations.translate(LStudentPanel.academicHistory, locale),
              Icons.history_edu_rounded,
              Colors.brown,
              () => context.go('/academic-history')
            ),
            (
              AppLocalizations.translate(LStudentPanel.studyPlanner, locale),
              Icons.event_note_rounded,
              Colors.lightBlue,
              () => context.go('/study-planner')
            ),
            (
              AppLocalizations.translate(LStudentPanel.onlineClasses, locale),
              Icons.videocam_rounded,
              Colors.deepPurple,
              () => context.go('/online-classes')
            ),
            (
              AppLocalizations.translate(LStudentPanel.careerGuidance, locale),
              Icons.explore_rounded,
              Colors.black87,
              () => context.go('/career-guidance')
            ),
            (
              AppLocalizations.translate(LStudentPanel.scholarships, locale),
              Icons.school_rounded,
              Colors.black87,
              () => context.go('/scholarships')
            ),
            (
              AppLocalizations.translate(LStudentPanel.sports, locale),
              Icons.sports_basketball_rounded,
              Colors.orange,
              () => context.go('/sports-activities')
            ),
            (
              AppLocalizations.translate(LStudentPanel.mentalHealth, locale),
              Icons.self_improvement_rounded,
              Colors.pink,
              () => context.go('/mental-health')
            ),
            (
              AppLocalizations.translate(LStudentPanel.subjectProgress, locale),
              Icons.trending_up_rounded,
              Colors.black87,
              () => context.go('/subject-progress')
            ),
            (
              AppLocalizations.translate(LStudentPanel.notifications, locale),
              Icons.notifications_rounded,
              Colors.pink,
              () => context.go('/student-notifications')
            ),
            (
              AppLocalizations.translate(LStudentPanel.myProfile, locale),
              Icons.person_rounded,
              Colors.grey,
              () => context.go('/student-profile')
            ),
            (
              AppLocalizations.translate(LStudentPanel.studyMaterials, locale),
              Icons.menu_book_rounded,
              Colors.lightBlue,
              () => context.go('/study-materials')
            ),
            (
              AppLocalizations.translate(LStudentPanel.feedback, locale),
              Icons.rate_review_rounded,
              Colors.lime,
              () => context.go('/feedback')
            ),
            (
              AppLocalizations.translate(LStudentPanel.helpSupport, locale),
              Icons.help_rounded,
              Colors.deepPurple,
              () => context.go('/help-support')
            ),
            (
              AppLocalizations.translate(LStudentPanel.privacySecurity, locale),
              Icons.security_rounded,
              Colors.grey,
              () => context.go('/privacy-security')
            ),
            (
              AppLocalizations.translate(LStudentPanel.digitalLibrary, locale),
              Icons.menu_book_rounded,
              Colors.black87,
              () => context.go('/digital-library')
            ),
            (
              AppLocalizations.translate(LStudentPanel.myDocuments, locale),
              Icons.folder_shared_rounded,
              Colors.brown,
              () => context.go('/student-documents')
            ),
            (
              AppLocalizations.translate(LStudentPanel.leaveApply, locale),
              Icons.event_busy_rounded,
              Colors.red,
              () => context.go('/student-leaves')
            ),
            (
              AppLocalizations.translate(LStudentPanel.placementTest, locale),
              Icons.spellcheck_rounded,
              Colors.deepPurple,
              () => context.go('/placement-test')
            ),
          ],
        ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
        const SizedBox(height: 24),

        // Section: Pending Assignments Table
        FutureBuilder(
          future: () async {
            final studentRows = await supabase
                .from('students')
                .select('id')
                .eq('profile_id', userId ?? '')
                .limit(1);
            final studentId = studentRows.isNotEmpty
                ? studentRows.first['id']
                : null;
            if (studentId == null) return <Map<String, dynamic>>[];
            final data = await supabase
                .from('student_assignments')
                .select()
                .eq('student_id', studentId)
                .eq('status', 'pending')
                .order('due_date', ascending: true)
                .limit(4);
            return (data as List).cast<Map<String, dynamic>>();
          }(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SkeletonDashboard();
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const SizedBox.shrink();
            }
            final assignments = snapshot.data as List;
            final rows = assignments.map((a) {
              return [
                a['title'] as String? ?? AppLocalizations.translate(LStudentPanel.untitled, locale),
                a['course_id'] != null ? AppLocalizations.translate(LStudentPanel.course, locale) : AppLocalizations.translate(LStudentPanel.subjectCol, locale),
                _formatDate(a['due_date'], locale),
                _getAssignmentPriority(a['due_date'], locale),
              ];
            }).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InsightSectionTitle(
                  title: AppLocalizations.translate(LStudentPanel.pendingAssignmentsTitle, locale),
                  subtitle: AppLocalizations.translate(LStudentPanel.pendingAssignmentsSub, locale),
                  trailing: TextButton(
                    onPressed: () => context.go('/assignments'),
                    child: Text(AppLocalizations.translate(LStudentPanel.viewAll, locale)),
                  ),
                ),
                const SizedBox(height: 12),
                InsightTableCard(
                  title: '',
                  subtitle: '',
                  columns: [
                    AppLocalizations.translate(LStudentPanel.assignmentCol, locale),
                    AppLocalizations.translate(LStudentPanel.subjectCol, locale),
                    AppLocalizations.translate(LStudentPanel.dueDateCol, locale),
                    AppLocalizations.translate(LStudentPanel.priorityCol, locale)
                  ],
                  rows: rows.isEmpty
                      ? [
                          [AppLocalizations.translate(LStudentPanel.noPendingAssignments, locale), '-', '-', '-']
                        ]
                      : rows,
                ),
              ],
            );
          },
        ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
        const SizedBox(height: 24),
        const AdBannerWidget(),
      ],
    );
  }

  String _getGradeStatus(String? grade, String locale) {
    if (grade == null) return '-';
    if (grade.startsWith('A')) return AppLocalizations.translate(LStudentPanel.excellent, locale);
    if (grade.startsWith('B')) return AppLocalizations.translate(LStudentPanel.good, locale);
    if (grade.startsWith('C')) return AppLocalizations.translate(LStudentPanel.average, locale);
    return AppLocalizations.translate(LStudentPanel.needsImprovement, locale);
  }

  String _formatDate(dynamic date, String locale) {
    if (date == null) return AppLocalizations.translate(LStudentPanel.noDueDate, locale);
    try {
      final dt = DateTime.parse(date.toString());
      final now = DateTime.now();
      final diff = dt.difference(now).inDays;
      if (diff == 0) return AppLocalizations.translate(LStudentPanel.today, locale);
      if (diff == 1) return AppLocalizations.translate(LStudentPanel.tomorrow, locale);
      if (diff < 0) return AppLocalizations.translate(LStudentPanel.overdue, locale);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return date.toString();
    }
  }

  String _getAssignmentPriority(dynamic dueDate, String locale) {
    if (dueDate == null) return AppLocalizations.translate(LStudentPanel.low, locale);
    try {
      final dt = DateTime.parse(dueDate.toString());
      final diff = dt.difference(DateTime.now()).inDays;
      if (diff <= 1) return AppLocalizations.translate(LStudentPanel.high, locale);
      if (diff <= 3) return AppLocalizations.translate(LStudentPanel.medium, locale);
      return AppLocalizations.translate(LStudentPanel.low, locale);
    } catch (e) {
      return AppLocalizations.translate(LStudentPanel.medium, locale);
    }
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Gradient gradient;
  final bool isOutlined;

  const _GradientButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.gradient,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isOutlined) {
      return Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        padding: const EdgeInsets.all(2),
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.primary,
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }
}
