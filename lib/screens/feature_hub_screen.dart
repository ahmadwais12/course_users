import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:course_users/theme.dart';
import 'package:course_users/widgets/insight_ui.dart';

class FeatureHubScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> highlights;

  const FeatureHubScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.highlights,
  });

  @override
  State<FeatureHubScreen> createState() => _FeatureHubScreenState();
}

class _FeatureHubScreenState extends State<FeatureHubScreen> {
  List<InsightPoint> _points = [];
  List<InsightSegment> _segments = [];
  List<List<String>> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // No weekly_activity / status_summary / module_items tables exist in the
    // schema, so render deterministic insight cards from static data.
    _points = List<InsightPoint>.generate(
      6,
      (index) => InsightPoint(
        ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][index],
        35 + (index * 8) + (widget.highlights.length * 2),
      ),
    );
    _segments = [
      InsightSegment(
          label: 'Healthy pipeline', value: 58, color: widget.color),
      const InsightSegment(
          label: 'Waiting review', value: 26, color: Colors.orange),
      const InsightSegment(
          label: 'Needs attention', value: 16, color: Colors.red),
    ];
    _rows = List<List<String>>.generate(
      4,
      (index) => [
        '${widget.title.split(' ').first} ${index + 1}',
        ['Operations', 'Academic', 'Finance', 'Support'][index],
        ['Active', 'Queued', 'In Review', 'Completed'][index],
        ['High', 'Medium', 'High', 'Low'][index],
      ],
    );
    _loading = false;
  }

  List<InsightFlowStep> _buildSteps() {
    return [
      InsightFlowStep(
        title: 'Intake',
        subtitle: 'Capture requests and queue the next action.',
        icon: widget.icon,
      ),
      const InsightFlowStep(
        title: 'Review',
        subtitle: 'Validate details and assign ownership.',
        icon: Icons.fact_check_outlined,
      ),
      const InsightFlowStep(
        title: 'Delivery',
        subtitle: 'Execute the task with service visibility.',
        icon: Icons.rocket_launch_outlined,
      ),
      const InsightFlowStep(
        title: 'Report',
        subtitle: 'Measure quality, timing, and completion.',
        icon: Icons.analytics_outlined,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: InsightBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              InsightHeroCard(
                eyebrow: 'Operational workspace',
                title: widget.title,
                subtitle: widget.subtitle,
                accent: widget.color,
                chips: [
                  InsightStatChip(
                      label: 'Highlights',
                      value: '${widget.highlights.length}'),
                  const InsightStatChip(label: 'Health', value: 'Stable'),
                  const InsightStatChip(label: 'Automation', value: 'Live'),
                ],
                actions: [
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_task_rounded),
                    label: const Text('Create Task'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.file_download_outlined),
                    label: const Text('Export'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.4)),
                    ),
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
                      label: 'Live items',
                      value: '${_rows.length * 9}',
                      trend: '+8.2%',
                      icon: widget.icon,
                      accent: widget.color,
                    ),
                  ),
                  SizedBox(
                    width: 240,
                    child: InsightMetricCard(
                      label: 'Resolved today',
                      value: '${widget.highlights.length + 14}',
                      trend: '+4.6%',
                      icon: Icons.check_circle_outline_rounded,
                      accent: Colors.black87,
                    ),
                  ),
                  SizedBox(
                    width: 240,
                    child: InsightMetricCard(
                      label: 'Pending approvals',
                      value: '${widget.highlights.length + 3}',
                      trend: '-2.1%',
                      icon: Icons.pending_actions_rounded,
                      accent: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              InsightSectionTitle(
                title: '${widget.title} insights',
                subtitle:
                    'A richer workspace with charts, process visibility, and review tables.',
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 840;

                  if (narrow) {
                    return Column(
                      children: [
                        InsightLineChartCard(
                          title: 'Trend line',
                          subtitle: 'Current week activity across the module.',
                          points: _points,
                          accent: widget.color,
                        ),
                        const SizedBox(height: 16),
                        InsightSegmentsCard(
                          title: 'Distribution',
                          subtitle:
                              'Balanced view of healthy, pending, and urgent work.',
                          segments: _segments,
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: InsightLineChartCard(
                          title: 'Trend line',
                          subtitle: 'Current week activity across the module.',
                          points: _points,
                          accent: widget.color,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InsightSegmentsCard(
                          title: 'Distribution',
                          subtitle:
                              'Balanced view of healthy, pending, and urgent work.',
                          segments: _segments,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              InsightProcessDiagram(
                title: 'Process diagram',
                subtitle:
                    'Move work from intake to completion with visible checkpoints.',
                steps: _buildSteps(),
                accent: widget.color,
              ),
              const SizedBox(height: 16),
              InsightTableCard(
                title: 'Operational table',
                subtitle:
                    'Snapshot of the latest work items linked to this module.',
                columns: const ['Item', 'Owner', 'Status', 'Priority'],
                rows: _rows,
              ),
              const SizedBox(height: 16),
              InsightPromoBanner(
                title: 'Promote this module with in-app ads',
                subtitle:
                    'Turn high-performing workflows into campaigns for courses, events, or services directly from the ads hub.',
                ctaLabel: 'Open Ads',
                accent: widget.color,
                icon: Icons.campaign_rounded,
                onTap: () => context.go('/ads'),
              ),
              const SizedBox(height: 22),
              Text(
                'Highlights',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              ...widget.highlights.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: widget.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(Icons.check_circle_rounded,
                            color: widget.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
