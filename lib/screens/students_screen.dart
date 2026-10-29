import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:course_users/models/program.dart';
import 'package:course_users/models/student.dart';
import 'package:course_users/providers/student_provider.dart';
import 'package:course_users/widgets/insight_ui.dart';
import 'package:course_users/widgets/modern_ui.dart';
import 'package:course_users/widgets/skeleton_loader.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  String _searchQuery = '';
  Map<ProgramType, List<int>> _durations = {};
  Map<int, double> _pricing = {};

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    try {
      final data = await Supabase.instance.client
          .from('programs')
          .select('code, duration_months, fee');
      if (!mounted) return;
      final durations = <ProgramType, List<int>>{};
      final pricing = <int, double>{};
      for (final row in data) {
        final code = row['code'] as String;
        final dur = row['duration_months'] as int;
        final fee = (row['fee'] as num).toDouble();
        final pt = ProgramType.values.where((e) => e.code == code).firstOrNull;
        if (pt == null) continue;
        durations.putIfAbsent(pt, () => []);
        if (!durations[pt]!.contains(dur)) {
          durations[pt]!.add(dur);
          durations[pt]!.sort();
        }
        pricing.putIfAbsent(dur, () => fee);
      }
      setState(() {
        _durations = durations;
        _pricing = pricing;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.file_download_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRegistrationDialog(context, ref),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Student'),
      ),
      body: InsightBackground(
        child: studentsAsync.when(
          data: (students) {
            final filtered = students
                .where(
                  (student) => student.id
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()),
                )
                .toList();

            final activeCount = students
                .where((student) => student.status == StudentStatus.active)
                .length;
            final outstandingCount = students
                .where((student) => student.hasOutstandingBalance)
                .length;
            final excellenceCount = students
                .where((student) => student.hasExcellenceDiscount)
                .length;

            return SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                children: [
                  const InsightHeroCard(
                    eyebrow: 'Student operations',
                    title: 'Student lifecycle and enrollment health',
                    subtitle:
                        'Monitor admissions, fee position, and academic readiness through a cleaner overview before diving into individual records.',
                    accent: Colors.black,
                    chips: [
                      InsightStatChip(label: 'Retention', value: '92%'),
                      InsightStatChip(label: 'Attendance', value: '89%'),
                      InsightStatChip(label: 'Risk alerts', value: '07'),
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
                          label: 'Active students',
                          value: '$activeCount',
                          trend: '+11%',
                          icon: Icons.groups_rounded,
                          accent: Colors.black87,
                        ),
                      ),
                      SizedBox(
                        width: 240,
                        child: InsightMetricCard(
                          label: 'Outstanding balances',
                          value: '$outstandingCount',
                          trend: outstandingCount > 0 ? 'Watch' : 'Clear',
                          icon: Icons.warning_amber_rounded,
                          accent: Colors.orange,
                        ),
                      ),
                      SizedBox(
                        width: 240,
                        child: InsightMetricCard(
                          label: 'Scholarship holders',
                          value: '$excellenceCount',
                          trend: '+3%',
                          icon: Icons.workspace_premium_outlined,
                          accent: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 840;
                      final lineCard = InsightLineChartCard(
                        title: 'Enrollment flow',
                        subtitle: 'Recent weekly student intake pacing.',
                        points: _buildEnrollmentPoints(students),
                        accent: Colors.black87,
                      );
                      final segmentsCard = InsightSegmentsCard(
                        title: 'Student mix',
                        subtitle:
                            'A quick split of active, pending fees, and scholarship students.',
                        segments: [
                          InsightSegment(
                            label: 'Active',
                            value: activeCount
                                .toDouble()
                                .clamp(1, double.infinity),
                            color: Colors.black87,
                          ),
                          InsightSegment(
                            label: 'Outstanding',
                            value: outstandingCount
                                .toDouble()
                                .clamp(1, double.infinity),
                            color: Colors.orange,
                          ),
                          InsightSegment(
                            label: 'Scholarship',
                            value: excellenceCount
                                .toDouble()
                                .clamp(1, double.infinity),
                            color: Colors.black87,
                          ),
                        ],
                      );

                      if (narrow) {
                        return Column(
                          children: [
                            lineCard,
                            const SizedBox(height: 16),
                            segmentsCard,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: lineCard),
                          const SizedBox(width: 16),
                          Expanded(child: segmentsCard),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const InsightProcessDiagram(
                    title: 'Student journey diagram',
                    subtitle:
                        'A clear path from lead registration to long-term retention.',
                    accent: Colors.black,
                    steps: [
                      InsightFlowStep(
                        title: 'Lead',
                        subtitle: 'Capture inquiry and qualification details.',
                        icon: Icons.person_search_outlined,
                      ),
                      InsightFlowStep(
                        title: 'Enroll',
                        subtitle: 'Confirm program, duration, and fee plan.',
                        icon: Icons.assignment_ind_outlined,
                      ),
                      InsightFlowStep(
                        title: 'Support',
                        subtitle: 'Track attendance, grades, and follow-up.',
                        icon: Icons.support_agent_outlined,
                      ),
                      InsightFlowStep(
                        title: 'Retain',
                        subtitle:
                            'Renew or move the student into the next offer.',
                        icon: Icons.favorite_outline_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InsightTableCard(
                    title: 'Student table',
                    subtitle:
                        'Key account and academic details for the latest students.',
                    columns: const ['Student', 'Program', 'Status', 'Balance'],
                    rows: _buildStudentRows(filtered),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    child: TextField(
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: 'Search students...',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 72,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No students found',
                            style: theme.textTheme.titleLarge,
                          ),
                        ],
                      ),
                    )
                  else
                    ...filtered.map(
                      (student) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _EnhancedStudentCard(
                          student: student,
                          onDelete: () => ref
                              .read(studentsNotifierProvider.notifier)
                              .deleteStudent(student.id),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          loading: () => const ListSkeleton(itemCount: 8),
          error: (err, stack) => Center(
            child: Text('Error: $err', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }

  List<InsightPoint> _buildEnrollmentPoints(List<Student> students) {
    final base = students.isEmpty ? 8 : students.length.toDouble();
    return [
      InsightPoint('Mon', base + 4),
      InsightPoint('Tue', base + 6),
      InsightPoint('Wed', base + 8),
      InsightPoint('Thu', base + 12),
      InsightPoint('Fri', base + 10),
      InsightPoint('Sat', base + 14),
    ];
  }

  List<List<String>> _buildStudentRows(List<Student> students) {
    if (students.isEmpty) {
      return const [
        ['No data', '-', '-', '-'],
      ];
    }

    return students.take(4).map((student) {
      return [
        student.id.substring(0, student.id.length.clamp(0, 14)),
        student.programId.replaceFirst('prog_', '').toUpperCase(),
        student.status.name.toUpperCase(),
        'PKR ${student.remainingBalance.toStringAsFixed(0)}',
      ];
    }).toList();
  }

  Future<void> _showRegistrationDialog(
      BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    ProgramType selectedProgram = ProgramType.cl;
    int selectedDuration = 4;
    double discount = 0;

    final durations = _durations.isNotEmpty
        ? _durations
        : {
            ProgramType.cl: [4],
            ProgramType.del: [6, 12],
            ProgramType.toefl: [6, 12],
            ProgramType.ielts: [6, 12],
          };

    final pricing =
        _pricing.isNotEmpty ? _pricing : {4: 40000.0, 6: 60000.0, 12: 120000.0};

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register Student'),
        content: StatefulBuilder(
          builder: (context, setLocal) {
            final totalFees = pricing[selectedDuration]! * (1 - discount / 100);
            return Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<ProgramType>(
                      initialValue: selectedProgram,
                      decoration: const InputDecoration(
                        labelText: 'Program',
                        prefixIcon: Icon(Icons.school),
                      ),
                      items: ProgramType.values
                          .take(4)
                          .map(
                            (program) => DropdownMenuItem(
                              value: program,
                              child: Text(program.code),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setLocal(() {
                            selectedProgram = value;
                            selectedDuration = durations[value]!.first;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: selectedDuration,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: durations[selectedProgram]!
                          .map(
                            (duration) => DropdownMenuItem(
                              value: duration,
                              child: Text('$duration months'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setLocal(() => selectedDuration = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: discount.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Discount',
                        prefixIcon: Icon(Icons.discount),
                        suffixText: '%',
                      ),
                      onChanged: (value) {
                        final parsed = double.tryParse(value) ?? 0;
                        setLocal(() => discount = parsed.clamp(0, 100));
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.08),
                      ),
                      child: Column(
                        children: [
                          _FeeRow(
                            'Base Fee',
                            'PKR ${pricing[selectedDuration]!.toStringAsFixed(0)}',
                          ),
                          if (discount > 0) ...[
                            const SizedBox(height: 8),
                            _FeeRow(
                              'Discount',
                              '-PKR ${(pricing[selectedDuration]! * discount / 100).toStringAsFixed(0)}',
                              color: Colors.black87,
                            ),
                          ],
                          const Divider(height: 24),
                          _FeeRow(
                            'Total',
                            'PKR ${totalFees.toStringAsFixed(0)}',
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final now = DateTime.now();
              final totalFees =
                  pricing[selectedDuration]! * (1 - discount / 100);
              final student = Student(
                id: 'student_${now.millisecondsSinceEpoch}',
                userId: 'user_${now.millisecondsSinceEpoch}',
                programId: 'prog_${selectedProgram.name}',
                duration: selectedDuration,
                classId: 'class_default',
                status: StudentStatus.active,
                totalFees: totalFees,
                paidAmount: 0,
                discount: discount,
                enrollmentDate: now,
                attendancePercentage: 0,
                averageGrade: 0,
                hasExcellenceDiscount: false,
                createdAt: now,
                updatedAt: now,
              );
              ref.read(studentsNotifierProvider.notifier).addStudent(student);
              Navigator.pop(context);
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isBold;

  const _FeeRow(this.label, this.value, {this.color, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.bold : null,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: isBold ? FontWeight.bold : null,
              ),
        ),
      ],
    );
  }
}

class _EnhancedStudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onDelete;

  const _EnhancedStudentCard({required this.student, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ModernCard(
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
                    gradient: LinearGradient(
                      colors: [Colors.black87.withValues(alpha: 0.8), Colors.black87],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student ${student.id.substring(8, 20)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${student.duration} months program',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                ModernBadge(
                  label: student.status.name.toUpperCase(),
                  color: student.status == StudentStatus.active
                      ? Colors.black87
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoColumn(
                    'Total Fees',
                    'PKR ${student.totalFees.toStringAsFixed(0)}',
                    Icons.attach_money,
                    Colors.black87,
                  ),
                ),
                Expanded(
                  child: _InfoColumn(
                    'Paid',
                    'PKR ${student.paidAmount.toStringAsFixed(0)}',
                    Icons.check_circle,
                    Colors.black87,
                  ),
                ),
                Expanded(
                  child: _InfoColumn(
                    'Balance',
                    'PKR ${student.remainingBalance.toStringAsFixed(0)}',
                    Icons.pending,
                    student.hasOutstandingBalance ? Colors.red : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton.outlined(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoColumn(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
