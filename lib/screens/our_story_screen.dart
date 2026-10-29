import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:course_users/components/skeleton_widgets.dart';

class OurStoryScreen extends StatefulWidget {
  const OurStoryScreen({super.key});

  @override
  State<OurStoryScreen> createState() => _OurStoryScreenState();
}

class _OurStoryScreenState extends State<OurStoryScreen> {
  List<Map<String, dynamic>> _milestones = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMilestones();
  }

  Future<void> _loadMilestones() async {
    try {
      final data = await Supabase.instance.client
          .from('home_hero_sections')
          .select('*')
          .eq('is_active', true)
          .order('display_order');
      if (mounted) {
        setState(() {
          _milestones = List<Map<String, dynamic>>.from(data);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Story'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our Story',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'DreamFlow was founded with a simple mission: to make education management easier, smarter, and more efficient for institutes around the world.',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'What started as a small project to help local language institutes manage their operations has grown into a comprehensive platform serving hundreds of institutes and thousands of students daily.',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            if (_loading)
              const SkeletonCard()
            else
              ..._buildMilestoneWidgets(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMilestoneWidgets() {
    final items = _milestones.isNotEmpty
        ? _milestones
        : [
            {
              'title': '2020',
              'subtitle': 'The Beginning',
              'content':
                  'DreamFlow was born from the need to simplify institute management.'
            },
            {
              'title': '2022',
              'subtitle': 'Growing Strong',
              'content':
                  'Expanded to serve 100+ institutes with advanced features.'
            },
            {
              'title': '2024',
              'subtitle': 'Platform Evolution',
              'content':
                  'Introduced AI-powered analytics and real-time collaboration tools.'
            },
            {
              'title': '2026',
              'subtitle': 'Leading Innovation',
              'content':
                  'Now serving 500+ institutes with 50k+ daily active students.'
            },
          ];
    final cards = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      final m = items[i];
      cards.add(_MilestoneCard(
        year: m['title'] ?? '',
        title: m['subtitle'] ?? m['title'] ?? '',
        description: m['content'] ?? m['description'] ?? '',
      ));
      if (i < items.length - 1) {
        cards.add(const SizedBox(height: 16));
      }
    }
    return cards;
  }
}

class _MilestoneCard extends StatelessWidget {
  final String year;
  final String title;
  final String description;

  const _MilestoneCard({
    required this.year,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              year,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
