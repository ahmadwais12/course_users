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

class ParentPanelScreen extends ConsumerWidget {
  const ParentPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentStatsAsync = ref.watch(parentStatsProvider);
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    final locale = ref.watch(localeProvider);

    return BasePanelLayout(
      title: AppLocalizations.translate(LParentPanel.title, locale),
      children: [
        // Hero Card with Key Metrics
        parentStatsAsync
            .when(
              data: (stats) {
                return InsightHeroCard(
                  eyebrow: AppLocalizations.translate(LParentPanel.eyebrow, locale),
                  title: AppLocalizations.translate(LParentPanel.welcomeBack, locale),
                  subtitle: AppLocalizations.translate(LParentPanel.subtitle, locale),
                  accent: Colors.black87,
                  chips: [
                    InsightStatChip(
                        label: AppLocalizations.translate(LParentPanel.children, locale),
                        value: '${stats.totalChildren} ${AppLocalizations.translate(LParentPanel.enrolled, locale)}'),
                    InsightStatChip(
                        label: AppLocalizations.translate(LParentPanel.attendance, locale),
                        value: '${stats.avgAttendance}% ${AppLocalizations.translate(LParentPanel.avg, locale)}'),
                    InsightStatChip(
                        label: AppLocalizations.translate(LParentPanel.feesDue, locale), value: '\$${stats.totalFeesDue}'),
                  ],
                  actions: [
                    _GradientButton(
                      onPressed: () => context.go('/payments'),
                      icon: Icons.payment_rounded,
                      label: AppLocalizations.translate(LParentPanel.payFees, locale),
                      gradient: AppGradients.skyCyanHorizontal,
                    ),
                    _GradientButton(
                      onPressed: () => context.go('/messages'),
                      icon: Icons.message_rounded,
                      label: AppLocalizations.translate(LParentPanel.contactSchool, locale),
                      gradient: AppGradients.blueHorizontal,
                      isOutlined: true,
                    ),
                  ],
                );
              },
              loading: () => const SkeletonDashboard(),
              error: (e, st) => InsightHeroCard(
                eyebrow: AppLocalizations.translate(LParentPanel.errorTitle, locale),
                title: AppLocalizations.translate(LParentPanel.errorTitle, locale),
                subtitle: AppLocalizations.translate(LParentPanel.errorSub, locale),
                accent: Colors.red,
                chips: const [],
                actions: [],
              ),
            )
            .animate()
            .fadeIn(duration: 800.ms)
            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
        const SizedBox(height: 24),

        // Section: Children Performance Table
        _buildChildrenPerformance(context, supabase, userId, locale),
        const SizedBox(height: 24),

        // Section: Charts Row
        _buildProgressAnalytics(context, supabase, userId, locale),
        const SizedBox(height: 24),

        // Section: Fee Payment Process Diagram
        InsightSectionTitle(
          title: AppLocalizations.translate(LParentPanel.feeProcess, locale),
          subtitle: AppLocalizations.translate(LParentPanel.feeProcessSub, locale),
        ),
        const SizedBox(height: 12),
        InsightProcessDiagram(
          title: '',
          subtitle: '',
          accent: Colors.orange,
          steps: [
            InsightFlowStep(
              title: AppLocalizations.translate(LParentPanel.viewInvoice, locale),
              subtitle: AppLocalizations.translate(LParentPanel.viewInvoiceSub, locale),
              icon: Icons.receipt_long_rounded,
            ),
            InsightFlowStep(
              title: AppLocalizations.translate(LParentPanel.selectMethod, locale),
              subtitle: AppLocalizations.translate(LParentPanel.selectMethodSub, locale),
              icon: Icons.account_balance_wallet_rounded,
            ),
            InsightFlowStep(
              title: AppLocalizations.translate(LParentPanel.confirm, locale),
              subtitle: AppLocalizations.translate(LParentPanel.confirmSub, locale),
              icon: Icons.payment_rounded,
            ),
            InsightFlowStep(
              title: AppLocalizations.translate(LParentPanel.receipt, locale),
              subtitle: AppLocalizations.translate(LParentPanel.receiptSub, locale),
              icon: Icons.check_circle_rounded,
            ),
          ],
        ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
        const SizedBox(height: 24),

        // Section: Metric Cards
        _buildQuickStats(context, supabase, locale),
        const SizedBox(height: 24),

        // Section: Parent Actions
        PanelSectionTitle(title: AppLocalizations.translate(LParentPanel.quickActions, locale)),
        PanelActionGrid(
          actions: [
            (
              AppLocalizations.translate(LParentPanel.myChildren, locale),
              Icons.family_restroom_rounded,
              Colors.black87,
              () => context.go('/children-profile')
            ),
            (
              AppLocalizations.translate(LParentPanel.feePayment, locale),
              Icons.account_balance_wallet_rounded,
              Colors.black87,
              () => context.go('/fee-payment-history')
            ),
            (
              AppLocalizations.translate(LParentPanel.attendance, locale),
              Icons.calendar_month_rounded,
              Colors.orange,
              () => context.go('/children-attendance')
            ),
            (
              AppLocalizations.translate(LParentPanel.reportCards, locale),
              Icons.description_rounded,
              Colors.purple,
              () => context.go('/report-cards')
            ),
            (
              AppLocalizations.translate(LParentPanel.noticeBoard, locale),
              Icons.campaign_rounded,
              Colors.red,
              () => context.go('/notice-board')
            ),
            (
              AppLocalizations.translate(LParentPanel.meetings, locale),
              Icons.groups_rounded,
              Colors.black87,
              () => context.go('/parent-teacher-meetings')
            ),
            (
              AppLocalizations.translate(LParentPanel.calendar, locale),
              Icons.event_rounded,
              Colors.black87,
              () => context.go('/school-calendar')
            ),
            (
              AppLocalizations.translate(LParentPanel.transport, locale),
              Icons.directions_bus_rounded,
              Colors.amber,
              () => context.go('/transport-tracking')
            ),
            (
              AppLocalizations.translate(LParentPanel.healthRecords, locale),
              Icons.favorite_rounded,
              Colors.pink,
              () => context.go('/health-records')
            ),
            (
              AppLocalizations.translate(LStudentPanel.leaveApply, locale),
              Icons.event_available_rounded,
              Colors.cyan,
              () => context.go('/parent-leave-applications')
            ),
            (
              AppLocalizations.translate(LParentPanel.complaints, locale),
              Icons.report_problem_rounded,
              Colors.deepOrange,
              () => context.go('/parent-complaints')
            ),
            (
              AppLocalizations.translate(LParentPanel.events, locale),
              Icons.celebration_rounded,
              Colors.deepPurple,
              () => context.go('/events-registration')
            ),
            (
              AppLocalizations.translate(LParentPanel.activities, locale),
              Icons.sports_soccer_rounded,
              Colors.lightBlue,
              () => context.go('/co-curricular-activities')
            ),
            (
              AppLocalizations.translate(LParentPanel.emergency, locale),
              Icons.emergency_rounded,
              Colors.redAccent,
              () => context.go('/emergency-contacts')
            ),
            (
              AppLocalizations.translate(L.profile, locale),
              Icons.person_rounded,
              Colors.grey,
              () => context.go('/parent-profile')
            ),
            (
              AppLocalizations.translate(LParentPanel.settings, locale),
              Icons.settings_rounded,
              Colors.grey,
              () => context.go('/parent-settings')
            ),
            (
              AppLocalizations.translate(LParentPanel.messages, locale),
              Icons.message_rounded,
              Colors.black87,
              () => context.go('/messages')
            ),
            (
              AppLocalizations.translate(LParentPanel.invoices, locale),
              Icons.receipt_long_rounded,
              Colors.black87,
              () => context.go('/invoices')
            ),
            (
              AppLocalizations.translate(LParentPanel.documents, locale),
              Icons.folder_rounded,
              Colors.brown,
              () => context.go('/parent-documents')
            ),
            (
              AppLocalizations.translate(LParentPanel.performance, locale),
              Icons.trending_up_rounded,
              Colors.black87,
              () => context.go('/performance-tracking')
            ),
          ],
        ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
        const SizedBox(height: 24),

        // Section: Recent Notifications Table
        _buildRecentNotifications(context, supabase, locale),
        const SizedBox(height: 24),
        const AdBannerWidget(),
      ],
    );
  }

  Widget _buildChildrenPerformance(
      BuildContext context, SupabaseClient supabase, String? userId, String locale) {
    return FutureBuilder(
      future: userId != null
          ? supabase
              .from('parent_students')
              .select('*, students(*, classes(name))')
              .eq('parent_id', userId)
              .withConverter((data) => data as List<dynamic>)
          : Future.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonDashboard();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return InsightSectionTitle(
            title: AppLocalizations.translate(LParentPanel.childrenPerformance, locale),
            subtitle: AppLocalizations.translate(LParentPanel.noChildren, locale),
          );
        }

        final links = snapshot.data!;
        final rows = <List<String>>[];

        for (final link in links) {
          final student = link['students'] as Map? ?? {};
          final classData = student['classes'];
          final studentName = student['full_name']?.toString() ?? AppLocalizations.translate(LParentPanel.nA, locale);
          final className = classData?['name']?.toString() ?? AppLocalizations.translate(LParentPanel.nA, locale);
          final avgGrade = student['average_grade']?.toString() ?? AppLocalizations.translate(LParentPanel.nA, locale);
          final attendance = student['attendance_percentage']?.toString() ?? AppLocalizations.translate(LParentPanel.nA, locale);
          final status = student['status']?.toString() ?? AppLocalizations.translate(LParentPanel.active, locale);

          rows.add([studentName, className, avgGrade, attendance, status]);
        }

        return Column(
          children: [
            InsightSectionTitle(
              title: AppLocalizations.translate(LParentPanel.childrenPerformance, locale),
              subtitle: AppLocalizations.translate(LParentPanel.currentSemester, locale),
              trailing: TextButton.icon(
                onPressed: () => context.go('/students'),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(AppLocalizations.translate(LParentPanel.viewAll, locale)),
              ),
            ),
            const SizedBox(height: 12),
            InsightTableCard(
              title: '',
              subtitle: '',
              columns: [
                AppLocalizations.translate(LParentPanel.studentCol, locale),
                AppLocalizations.translate(LParentPanel.classCol, locale),
                AppLocalizations.translate(LParentPanel.avgGradeCol, locale),
                AppLocalizations.translate(LParentPanel.attendanceCol, locale),
                AppLocalizations.translate(LParentPanel.statusCol, locale)
              ],
              rows: rows.isNotEmpty
                  ? rows
                  : [
                      [AppLocalizations.translate(LParentPanel.noData, locale), '-', '-', '-', '-']
                    ],
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
          ],
        );
      },
    );
  }

  Widget _buildProgressAnalytics(
      BuildContext context, SupabaseClient supabase, String? userId, String locale) {
    return FutureBuilder(
      future: userId != null
          ? () async {
              // Resolve the child's student record for this parent.
              final links = await supabase
                  .from('parent_students')
                  .select('student_id')
                  .eq('parent_id', userId)
                  .limit(1);
              final studentId = links.isNotEmpty
                  ? links.first['student_id']
                  : null;
              if (studentId == null) return <dynamic>[];
              return supabase
                  .from('grades')
                  .select('score, created_at')
                  .eq('student_id', studentId)
                  .order('created_at', ascending: true)
                  .limit(6)
                  .withConverter((data) => data as List<dynamic>);
            }()
          : Future.value([]),
      builder: (context, snapshot) {
        final months = ['Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan'];
        List<InsightPoint> attendancePoints = [];
        List<InsightSegment> gradeSegments = [];

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final grades = snapshot.data!;
          for (int i = 0; i < grades.length && i < 6; i++) {
            final score =
                double.tryParse(grades[i]['score']?.toString() ?? '0') ?? 0;
            final monthIdx = i < months.length ? i : months.length - 1;
            attendancePoints
                .add(InsightPoint(months[monthIdx], score.toDouble()));
          }

          // Calculate grade distribution
          int aCount = 0, bCount = 0, cCount = 0, dCount = 0;
          for (final grade in grades) {
            final score =
                double.tryParse(grade['score']?.toString() ?? '0') ?? 0;
            if (score >= 90) {
              aCount++;
            } else if (score >= 80) {
              bCount++;
            } else if (score >= 70) {
              cCount++;
            } else {
              dCount++;
            }
          }

          final total = grades.length;
          if (total > 0) {
            gradeSegments = [
              InsightSegment(
                  label: AppLocalizations.translate(LParentPanel.aExcellent, locale),
                  value: ((aCount * 100) / total).toDouble(),
                  color: Colors.black87),
              InsightSegment(
                  label: AppLocalizations.translate(LParentPanel.bGood, locale),
                  value: ((bCount * 100) / total).toDouble(),
                  color: Colors.black87),
              InsightSegment(
                  label: AppLocalizations.translate(LParentPanel.cAverage, locale),
                  value: ((cCount * 100) / total).toDouble(),
                  color: Colors.orange),
              InsightSegment(
                  label: AppLocalizations.translate(LParentPanel.dBelow, locale),
                  value: ((dCount * 100) / total).toDouble(),
                  color: Colors.red),
            ];
          }
        }

        if (attendancePoints.isEmpty) {
          attendancePoints = [
            InsightPoint('Aug', 0),
            InsightPoint('Sep', 0),
            InsightPoint('Oct', 0),
          ];
          gradeSegments = [
            InsightSegment(label: AppLocalizations.translate(LParentPanel.noDataSegment, locale), value: 100, color: Colors.grey),
          ];
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InsightLineChartCard(
                title: AppLocalizations.translate(LParentPanel.attendanceTrend, locale),
                subtitle: 'Last 6 months',
                accent: Colors.black87,
                points: attendancePoints,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InsightSegmentsCard(
                title: AppLocalizations.translate(LParentPanel.gradeDistribution, locale),
                subtitle: AppLocalizations.translate(LParentPanel.currentSemester, locale),
                segments: gradeSegments,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms);
      },
    );
  }

  Widget _buildQuickStats(BuildContext context, SupabaseClient supabase, String locale) {
    return FutureBuilder(
      future: Future.wait([
        supabase
            .from('exams')
            .select('id')
            .gte('exam_date', DateTime.now().toIso8601String())
            .withConverter((data) => data as List<dynamic>),
        supabase
            .from('events')
            .select('id')
            .gte('start_date', DateTime.now().toIso8601String())
            .withConverter((data) => data as List<dynamic>),
        supabase
            .from('parent_messages')
            .select('id')
            .eq('read', false)
            .withConverter((data) => data as List<dynamic>),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        int examCount = 0;
        int eventCount = 0;
        int messageCount = 0;

        if (snapshot.hasData) {
          examCount = (snapshot.data![0] as List).length;
          eventCount = (snapshot.data![1] as List).length;
          messageCount = (snapshot.data![2] as List).length;
        }

        return Row(
          children: [
            Expanded(
              child: InsightMetricCard(
                label: AppLocalizations.translate(LParentPanel.upcomingExams, locale),
                value: examCount.toString(),
                trend: examCount > 0 ? AppLocalizations.translate(LParentPanel.nextCheckSchedule, locale) : AppLocalizations.translate(LParentPanel.none, locale),
                icon: Icons.assignment_rounded,
                accent: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InsightMetricCard(
                label: AppLocalizations.translate(LParentPanel.schoolEvents, locale),
                value: eventCount.toString(),
                trend: eventCount > 0 ? AppLocalizations.translate(LParentPanel.thisMonth, locale) : AppLocalizations.translate(LParentPanel.none, locale),
                icon: Icons.event_rounded,
                accent: Colors.black87,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InsightMetricCard(
                label: AppLocalizations.translate(LParentPanel.messages, locale),
                value: messageCount.toString(),
                trend: messageCount > 0 ? AppLocalizations.translate(LParentPanel.unread, locale) : AppLocalizations.translate(LParentPanel.allRead, locale),
                icon: Icons.message_rounded,
                accent: Colors.black87,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 500.ms, duration: 600.ms);
      },
    );
  }

  Widget _buildRecentNotifications(
      BuildContext context, SupabaseClient supabase, String locale) {
    return FutureBuilder(
      future: supabase
          .from('announcements')
          .select('title, type, publish_date, status')
          .order('publish_date', ascending: false)
          .limit(4)
          .withConverter((data) => data as List<dynamic>),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonDashboard();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return InsightSectionTitle(
            title: AppLocalizations.translate(LParentPanel.recentNotifications, locale),
            subtitle: AppLocalizations.translate(LParentPanel.noNotifications, locale),
          );
        }

        final announcements = snapshot.data!;
        final rows = <List<String>>[];

        for (final announcement in announcements) {
          final title = announcement['title']?.toString() ?? AppLocalizations.translate(LParentPanel.untitled, locale);
          final category = announcement['type']?.toString() ?? AppLocalizations.translate(LParentPanel.general, locale);
          final date = announcement['publish_date']?.toString() ?? AppLocalizations.translate(LParentPanel.noDate, locale);
          final status = announcement['status']?.toString() ?? AppLocalizations.translate(LParentPanel.active, locale);

          rows.add([title, category, date, status]);
        }

        return Column(
          children: [
            InsightSectionTitle(
              title: AppLocalizations.translate(LParentPanel.recentNotifications, locale),
              subtitle: AppLocalizations.translate(LParentPanel.latestUpdates, locale),
              trailing: TextButton(
                onPressed: () => context.go('/notice-board'),
                child: Text(AppLocalizations.translate(LParentPanel.viewAll, locale)),
              ),
            ),
            const SizedBox(height: 12),
            InsightTableCard(
              title: '',
              subtitle: '',
              columns: [
                AppLocalizations.translate(LParentPanel.notificationCol, locale),
                AppLocalizations.translate(LParentPanel.categoryCol, locale),
                AppLocalizations.translate(LParentPanel.dateCol, locale),
                AppLocalizations.translate(LParentPanel.statusCol, locale),
              ],
              rows: rows.isNotEmpty
                  ? rows
                  : [
                      [AppLocalizations.translate(LParentPanel.noData, locale), '-', '-', '-']
                    ],
            ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
          ],
        );
      },
    );
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
