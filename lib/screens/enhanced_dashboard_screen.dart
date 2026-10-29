import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:course_users/widgets/dashboard_components.dart';

class EnhancedDashboardScreen extends StatefulWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  State<EnhancedDashboardScreen> createState() =>
      _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<EnhancedDashboardScreen> {
  String _userName = 'User';
  String _totalStudents = '—';
  String _activeCourses = '—';
  String _completionRate = '—';
  String _revenue = '—';
  String _welcomeEnrolled = '—';
  String _welcomeCompleted = '—';
  String _welcomeInProgress = '—';

  List<double> _monthlyEnrollments = [];
  List<String> _monthlyLabels = [];
  List<Map<String, dynamic>> _subjectPerformance = [];
  List<Map<String, dynamic>> _courseStatusSections = [];
  List<double> _learningProgress = [];
  List<String> _learningLabels = [];
  List<Map<String, dynamic>> _recentEnrollments = [];
  List<Map<String, dynamic>> _progressCards = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final client = Supabase.instance.client;

      final user = client.auth.currentUser;
      final fullName = user?.userMetadata?['full_name'] as String? ?? 'User';

      final studentsData = await client.from('students').select();
      final programsData = await client.from('programs').select();
      final paymentsData = await client.from('payments').select();

      final totalStudents = studentsData.length;
      final activeCourses =
          programsData.where((p) => p['isActive'] == true).length;

      final paidPayments = paymentsData.where((p) => p['status'] == 'paid');
      final totalRevenue = paidPayments.fold<double>(
          0, (sum, p) => sum + (p['amount'] as num).toDouble());

      final completedStudents =
          studentsData.where((s) => s['status'] == 'graduated').length;
      final completionRate = totalStudents > 0
          ? (completedStudents / totalStudents * 100).round()
          : 0;

      final activeStudents =
          studentsData.where((s) => s['status'] == 'active').length;
      final graduatedStudents =
          studentsData.where((s) => s['status'] == 'graduated').length;
      final suspendedStudents =
          studentsData.where((s) => s['status'] == 'suspended').length;
      final inactiveStudents =
          studentsData.where((s) => s['status'] == 'inactive').length;

      final now = DateTime.now();
      final currentYear = now.year;

      final monthLabels = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final monthlyEnrollments = List.generate(12, (i) {
        final month = i + 1;
        final count = studentsData.where((s) {
          final date = DateTime.tryParse(s['enrollmentDate'] ?? '');
          return date != null &&
              date.year == currentYear &&
              date.month == month;
        }).length;
        return count.toDouble();
      });
      final maxMonthly = monthlyEnrollments.reduce((a, b) => a > b ? a : b);
      final scaledMonthly = monthlyEnrollments
          .map((v) =>
              maxMonthly > 0 ? (v / maxMonthly * 100).clamp(5, 100) : 10.0)
          .toList()
          .cast<double>();

      final subjectPerformance = programsData.take(5).map((p) {
        final pId = p['id'] as String;
        final pName = p['name'] as String;
        final pStudents =
            studentsData.where((s) => s['programId'] == pId).toList();
        final avgGrade = pStudents.isEmpty
            ? 0.0
            : pStudents.fold<double>(
                    0,
                    (sum, s) =>
                        sum + ((s['averageGrade'] as num?)?.toDouble() ?? 0)) /
                pStudents.length;
        return {
          'label': pName,
          'value': avgGrade.clamp(1, 100),
        };
      }).toList();

      final totalForSections = totalStudents > 0 ? totalStudents : 1;
      final courseStatusSections = [
        {
          'value': (graduatedStudents * 100 / totalForSections).round(),
          'label': 'Completed',
          'color': Colors.black87
        },
        {
          'value': (activeStudents * 100 / totalForSections).round(),
          'label': 'In Progress',
          'color': Colors.black87
        },
        {
          'value': (inactiveStudents * 100 / totalForSections).round(),
          'label': 'Not Started',
          'color': Colors.orange
        },
        {
          'value': (suspendedStudents * 100 / totalForSections).round(),
          'label': 'Dropped',
          'color': Colors.red
        },
      ];

      final weekLabels = List.generate(10, (i) => 'W${i + 1}');
      final rawLearning = List.generate(10, (i) {
        final weekStart = now.subtract(Duration(days: (9 - i) * 7 + 7));
        final weekEnd = weekStart.add(const Duration(days: 7));
        final count = studentsData.where((s) {
          final date = DateTime.tryParse(s['enrollmentDate'] ?? '');
          return date != null &&
              date.isAfter(weekStart) &&
              date.isBefore(weekEnd);
        }).length;
        return count.toDouble();
      });
      final maxLearning = rawLearning.reduce((a, b) => a > b ? a : b);
      final scaledLearning = rawLearning
          .map((v) =>
              maxLearning > 0 ? (v / maxLearning * 100).clamp(5, 100) : 10.0)
          .toList()
          .cast<double>();

      final recentEnrollments = studentsData.take(5).toList();
      final recentData = recentEnrollments.map((s) {
        final pId = s['programId'] as String? ?? '';
        final prog = programsData.where((p) => p['id'] == pId).firstOrNull;
        final progName = prog?['name'] as String? ?? 'Program';
        final date = DateTime.tryParse(s['enrollmentDate'] ?? '');
        final dateStr =
            date != null ? '${monthLabels[date.month - 1]} ${date.day}' : '—';
        final status = (s['status'] as String?) ?? 'active';
        return {
          'student':
              'Student ${s['id'].toString().length > 8 ? s['id'].toString().substring(0, 8) : s['id']}',
          'course': progName,
          'date': dateStr,
          'status': status,
        };
      }).toList();

      final progressCardsData = studentsData.take(4).toList();
      final progressCards = progressCardsData.map((s) {
        final pId = s['programId'] as String? ?? '';
        final prog = programsData.where((p) => p['id'] == pId).firstOrNull;
        final progName = prog?['name'] as String? ?? 'Course';
        final progress =
            ((s['attendancePercentage'] as num?)?.toDouble() ?? 50) / 100;
        final grade = ((s['averageGrade'] as num?)?.toDouble() ?? 0).round();
        return {
          'title': progName,
          'progress': progress.clamp(0.0, 1.0),
          'color':
              _cardColors[progressCardsData.indexOf(s) % _cardColors.length],
          'subtitle': 'Grade: $grade%',
        };
      }).toList();

      if (mounted) {
        setState(() {
          _userName = fullName;
          _totalStudents = _formatNumber(totalStudents);
          _activeCourses = '$activeCourses';
          _completionRate = '$completionRate%';
          _revenue = _formatCurrency(totalRevenue);
          _welcomeEnrolled = '$activeStudents';
          _welcomeCompleted = '$graduatedStudents';
          _welcomeInProgress = '$activeStudents';
          _monthlyEnrollments = scaledMonthly;
          _monthlyLabels = monthLabels;
          _subjectPerformance = subjectPerformance;
          _courseStatusSections = courseStatusSections;
          _learningProgress = scaledLearning;
          _learningLabels = weekLabels;
          _recentEnrollments = recentData;
          _progressCards = progressCards;
        });
      }
    } catch (e) {
      // Silently ignore dashboard data load failures.
    }
  }

  final List<Color> _cardColors = [
    Colors.black87,
    Colors.black87,
    Colors.orange,
    Colors.purple,
  ];

  String _formatNumber(int n) {
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
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(context),
            const SizedBox(height: 24),
            _buildStatsGrid(context),
            const SizedBox(height: 24),
            Text(
              'Analytics Overview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildChartsRow1(context),
            const SizedBox(height: 24),
            _buildChartsRow2(context),
            const SizedBox(height: 24),
            Text(
              'Course Progress',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressSection(context),
            const SizedBox(height: 24),
            _buildDataTable(context),
            const SizedBox(height: 24),
            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWelcomeStat('Enrolled', _welcomeEnrolled, Icons.book),
                _buildWelcomeStat(
                    'Completed', _welcomeCompleted, Icons.check_circle),
                _buildWelcomeStat(
                    'In Progress', _welcomeInProgress, Icons.pending),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        DashboardStatCard(
          title: 'Total Students',
          value: _totalStudents,
          icon: Icons.people,
          color: Colors.black87,
          subtitle: '+12% this month',
          percentageChange: 12.5,
        ),
        DashboardStatCard(
          title: 'Active Courses',
          value: _activeCourses,
          icon: Icons.school,
          color: Colors.black87,
          subtitle: '8 new this week',
          percentageChange: 8.3,
        ),
        DashboardStatCard(
          title: 'Completion Rate',
          value: _completionRate,
          icon: Icons.trending_up,
          color: Colors.orange,
          subtitle: 'Above average',
          percentageChange: 5.2,
        ),
        DashboardStatCard(
          title: 'Revenue',
          value: _revenue,
          icon: Icons.attach_money,
          color: Colors.purple,
          subtitle: '+18% growth',
          percentageChange: 18.7,
        ),
      ],
    );
  }

  Widget _buildChartsRow1(BuildContext context) {
    return Column(
      children: [
        ProgressLineChart(
          data: _monthlyEnrollments,
          labels: _monthlyLabels,
          lineColor: Colors.black87,
          title: 'Monthly Enrollment Trend',
        ),
        const SizedBox(height: 16),
        ComparisonBarChart(
          data: _subjectPerformance,
          title: 'Subject Performance',
          barColor: Colors.black87,
        ),
      ],
    );
  }

  Widget _buildChartsRow2(BuildContext context) {
    return Column(
      children: [
        DistributionPieChart(
          sections: _courseStatusSections,
          title: 'Course Status Distribution',
        ),
        const SizedBox(height: 16),
        ProgressLineChart(
          data: _learningProgress,
          labels: _learningLabels,
          lineColor: Colors.purple,
          title: 'Learning Progress',
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Column(
      children: _progressCards.map((card) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProgressCard(
            title: card['title'] as String,
            progress: card['progress'] as double,
            color: card['color'] as Color,
            subtitle: card['subtitle'] as String?,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    return EnhancedDataTable(
      title: 'Recent Enrollments',
      icon: Icons.list_alt,
      columns: ['Student', 'Course', 'Date', 'Status'],
      rows: _recentEnrollments.map((e) {
        final status = e['status'] as String;
        final statusColor = status == 'active'
            ? Colors.black87
            : status == 'graduated'
                ? Colors.black87
                : status == 'suspended'
                    ? Colors.red
                    : Colors.orange;
        return [
          e['student'] as String,
          e['course'] as String,
          e['date'] as String,
          _buildStatusChip(
            status == 'active'
                ? 'Active'
                : status == 'graduated'
                    ? 'Completed'
                    : status == 'suspended'
                        ? 'Dropped'
                        : 'Pending',
            statusColor,
          ),
        ];
      }).toList(),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildQuickActionCard(
            context, 'Browse Courses', Icons.search, Colors.black87),
        _buildQuickActionCard(
            context, 'My Learning', Icons.school, Colors.black87),
        _buildQuickActionCard(
            context, 'Certificates', Icons.emoji_events, Colors.orange),
        _buildQuickActionCard(
            context, 'Messages', Icons.message, Colors.purple),
        _buildQuickActionCard(context, 'Settings', Icons.settings, Colors.grey),
        _buildQuickActionCard(context, 'Help', Icons.help, Colors.red),
      ],
    );
  }

  Widget _buildQuickActionCard(
      BuildContext context, String label, IconData icon, Color color) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
