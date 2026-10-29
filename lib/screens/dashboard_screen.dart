import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:course_users/l10n/app_localizations.dart';
import 'package:course_users/widgets/insight_ui.dart';
import 'package:course_users/widgets/sign_out_dialog.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _studentCount = '—';
  String _collectionRate = '—';
  String _activeCampaigns = '—';
  String _enrollments = '—';
  String _revenue = '—';
  String _completion = '—';
  List<InsightPoint> _chartPoints = [];
  List<InsightSegment> _segments = [];
  List<List<String>> _watchlistRows = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final client = Supabase.instance.client;

      final studentsData = await client.from('students').select();
      final paymentsData = await client.from('payments').select();
      final programsData = await client.from('programs').select();

      final studentCount = studentsData.length;

      final paidCount = paymentsData.where((p) => p['status'] == 'paid').length;
      final totalPayments = paymentsData.length;
      final collectionRate =
          totalPayments > 0 ? (paidCount / totalPayments * 100).round() : 0;

      final activePrograms =
          programsData.where((p) => p['isActive'] == true).length;

      final revenue = paymentsData
          .where((p) => p['status'] == 'paid')
          .fold<double>(0, (sum, p) => sum + (p['amount'] as num).toDouble());

      final completedStudents =
          studentsData.where((s) => s['status'] == 'graduated').length;
      final completionRate = studentCount > 0
          ? (completedStudents / studentCount * 100).round()
          : 0;

      final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 6));
      final recentStudents = studentsData.where((s) {
        final date = DateTime.tryParse(s['enrollmentDate'] ?? '');
        return date != null && date.isAfter(weekAgo);
      }).toList();
      final chartPoints = weekDays.map((day) {
        final dayIndex = _dayIndex(day);
        final count = recentStudents.where((s) {
          final date = DateTime.tryParse(s['enrollmentDate'] ?? '');
          return date != null && date.weekday == dayIndex;
        }).length;
        return InsightPoint(day, count > 0 ? count.toDouble() : 3.0);
      }).toList();

      final activeCount =
          studentsData.where((s) => s['status'] == 'active').length;
      final graduatedCount =
          studentsData.where((s) => s['status'] == 'graduated').length;
      final suspendedCount =
          studentsData.where((s) => s['status'] == 'suspended').length;
      final inactiveCount =
          studentsData.where((s) => s['status'] == 'inactive').length;
      final segments = [
        InsightSegment(
            label: 'Active',
            value: (activeCount > 0 ? activeCount : 1).toDouble(),
            color: Colors.black),
        InsightSegment(
            label: 'Graduated',
            value: (graduatedCount > 0 ? graduatedCount : 1).toDouble(),
            color: Colors.black87),
        InsightSegment(
            label: 'Suspended',
            value: (suspendedCount > 0 ? suspendedCount : 1).toDouble(),
            color: Colors.orange),
        InsightSegment(
            label: 'Inactive',
            value: (inactiveCount > 0 ? inactiveCount : 1).toDouble(),
            color: Colors.pink),
      ];

      final overdueCount =
          paymentsData.where((p) => p['status'] == 'overdue').length;
      final watchlistRows = [
        ['Students', 'Front Desk', 'Active', '$_formatStudentCount total'],
        [
          'Finance',
          'Accounts',
          overdueCount > 0 ? 'Watch' : 'Healthy',
          '$overdueCount overdue payments'
        ],
        ['Programs', 'Academic', 'Stable', '$activePrograms active programs'],
        [
          'Enrollments',
          'Support',
          studentCount > 0 ? 'Active' : 'Quiet',
          '${studentCount - completedStudents} in progress'
        ],
      ];

      if (mounted) {
        setState(() {
          _studentCount = _formatStudentCount(studentCount);
          _collectionRate = '$collectionRate%';
          _activeCampaigns = '$activePrograms';
          _enrollments = _formatStudentCount(studentCount);
          _revenue = _formatCurrency(revenue);
          _completion = '$completionRate%';
          _chartPoints = chartPoints;
          _segments = segments;
          _watchlistRows = watchlistRows;
        });
      }
    } catch (e) {
      // Silently ignore dashboard data load failures.
    }
  }

  int _dayIndex(String day) {
    switch (day) {
      case 'Mon':
        return 1;
      case 'Tue':
        return 2;
      case 'Wed':
        return 3;
      case 'Thu':
        return 4;
      case 'Fri':
        return 5;
      case 'Sat':
        return 6;
      default:
        return 0;
    }
  }

  String _formatStudentCount(int n) {
    final str = n.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'PKR ${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return 'PKR ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return 'PKR ${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final locale = ref.watch(localeProvider);

    final role = user?.userMetadata?['role']?.toString().toLowerCase();
    if (role != null && role != 'dashboard') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (role == 'student') context.go('/student-panel');
        if (role == 'parent') context.go('/parent-panel');
        if (role == 'staff') context.go('/staff-panel');
      });
    }

    final firstName =
        user?.userMetadata?['full_name']?.toString().split(' ').first ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translate('dashboard', locale)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              final shouldSignOut = await showSignOutDialog(context, locale);
              if (!shouldSignOut) return;
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: InsightBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              InsightHeroCard(
                eyebrow: 'Executive command center',
                title: 'Welcome back, $firstName',
                subtitle:
                    'Track academics, finance, operations, and promotional activity from one dashboard with a cleaner visual hierarchy.',
                accent: Colors.black,
                chips: [
                  InsightStatChip(label: 'Students', value: _studentCount),
                  InsightStatChip(
                      label: 'Collection rate', value: _collectionRate),
                  InsightStatChip(
                      label: 'Active campaigns', value: _activeCampaigns),
                ],
                actions: [
                  FilledButton.icon(
                    onPressed: () => context.go('/students'),
                    icon: const Icon(Icons.groups_rounded),
                    label: const Text('Open Students'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => context.go('/reports'),
                    icon: const Icon(Icons.analytics_outlined),
                    label: const Text('View Reports'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 240,
                    child: InsightMetricCard(
                      label: 'New enrollments',
                      value: _enrollments,
                      trend: '+12%',
                      icon: Icons.person_add_alt_1_rounded,
                      accent: Colors.black87,
                    ),
                  ),
                  SizedBox(
                    width: 240,
                    child: InsightMetricCard(
                      label: 'Revenue collected',
                      value: _revenue,
                      trend: '+9%',
                      icon: Icons.payments_rounded,
                      accent: Colors.black87,
                    ),
                  ),
                  SizedBox(
                    width: 240,
                    child: InsightMetricCard(
                      label: 'Course completion',
                      value: _completion,
                      trend: '+5%',
                      icon: Icons.school_rounded,
                      accent: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 840;
                  final lineCard = InsightLineChartCard(
                    title: 'Enrollment momentum',
                    subtitle:
                        'Seven-day growth across the admissions pipeline.',
                    points: _chartPoints,
                    accent: Colors.black87,
                  );
                  final segmentCard = InsightSegmentsCard(
                    title: 'Operational split',
                    subtitle: 'Where the team is spending focus this week.',
                    segments: _segments,
                  );

                  if (narrow) {
                    return Column(
                      children: [
                        lineCard,
                        const SizedBox(height: 16),
                        segmentCard,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: lineCard),
                      const SizedBox(width: 16),
                      Expanded(child: segmentCard),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              const InsightProcessDiagram(
                title: 'Institute workflow diagram',
                subtitle:
                    'The redesigned dashboard ties together intake, learning, payment, and promotion.',
                accent: Colors.black,
                steps: [
                  InsightFlowStep(
                    title: 'Lead capture',
                    subtitle: 'Collect admissions and ad-driven inquiries.',
                    icon: Icons.ads_click_outlined,
                  ),
                  InsightFlowStep(
                    title: 'Enrollment',
                    subtitle: 'Register students and place them into programs.',
                    icon: Icons.assignment_ind_outlined,
                  ),
                  InsightFlowStep(
                    title: 'Delivery',
                    subtitle: 'Run classes, attendance, and support follow-up.',
                    icon: Icons.cast_for_education_outlined,
                  ),
                  InsightFlowStep(
                    title: 'Retention',
                    subtitle:
                        'Track renewals, upsell offers, and campaign response.',
                    icon: Icons.trending_up_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InsightTableCard(
                title: 'Priority watchlist',
                subtitle:
                    'A compact table for the items leadership usually checks first.',
                columns: ['Area', 'Owner', 'Status', 'Next action'],
                rows: _watchlistRows,
              ),
              const SizedBox(height: 16),
              InsightPromoBanner(
                title: 'Promote your next intake directly in the app',
                subtitle:
                    'Use the new ads pages to run course promotions, scholarship campaigns, and event announcements from the same platform.',
                ctaLabel: 'Launch Ads',
                accent: const Color(0xFFDB2777),
                icon: Icons.campaign_rounded,
                onTap: () => context.go('/ads'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
