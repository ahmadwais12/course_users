import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:course_users/providers/home_provider.dart';
import 'package:course_users/l10n/app_localizations.dart';
import 'package:course_users/l10n/locale_keys.dart';
import 'package:course_users/widgets/paginated_list_view.dart';

// Our Courses Screen
class OurCoursesScreen extends ConsumerStatefulWidget {
  const OurCoursesScreen({super.key});

  @override
  ConsumerState<OurCoursesScreen> createState() => _OurCoursesScreenState();
}

class _OurCoursesScreenState extends ConsumerState<OurCoursesScreen> {
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translate(LHome.ourCoursesTitle, locale)),
        centerTitle: true,
      ),
      body: PaginatedGridView<Map<String, dynamic>>(
        fetcher: _fetchCoursesPage,
        pageSize: 12,
        skeleton: (context) => const SkeletonGridPage(itemCount: 8),
        empty: (context, _) => Center(
          child: Text(AppLocalizations.translate(LHome.noCourses, locale)),
        ),
        itemBuilder: (context, course, index) => _CourseCard(
          name: course['name'] as String? ?? '',
          level: course['code'] as String? ?? '',
          duration: '${course['credits'] ?? 0} credits',
          icon: Icons.book,
          locale: locale,
          color: [
            Colors.black87,
            Colors.black87,
            Colors.orange,
            Colors.purple,
            Colors.black87,
            Colors.pink
          ][index % 6],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchCoursesPage(
      int page, int pageSize) async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('courses')
          .select()
          .eq('status', 'Active')
          .order('created_at', ascending: true)
          .range(page * pageSize, page * pageSize + pageSize - 1);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}

class _CourseCard extends StatelessWidget {
  final String name;
  final String level;
  final String duration;
  final IconData icon;
  final Color color;
  final String locale;

  const _CourseCard({
    required this.name,
    required this.level,
    required this.duration,
    required this.icon,
    required this.color,
    this.locale = 'en',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.translate(LHome.levelFmt, locale).replaceAll('%s', level),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            AppLocalizations.translate(LHome.durationFmt, locale).replaceAll('%s', duration),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

// Our Branches Screen
class OurBranchesScreen extends ConsumerWidget {
  const OurBranchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final branchesAsync = ref.watch(activeBranchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translate(LHome.ourBranchesTitle, locale)),
        centerTitle: true,
      ),
      body: branchesAsync.when(
        data: (branches) {
          if (branches.isEmpty) {
            return Center(child: Text(AppLocalizations.translate(LHome.noBranches, locale)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final branch = branches[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _mapBranchIcon(
                              branch['is_headquarters'] == true
                                  ? 'main'
                                  : ''),
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              branch['name'] as String? ?? '',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              branch['address'] as String? ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              branch['city'] as String? ??
                                  branch['province'] as String? ??
                                  '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const SkeletonListPage(itemCount: 6),
        error: (error, stack) =>
            Center(child: Text(AppLocalizations.translate(LHome.failedToLoad, locale))),
      ),
    );
  }
}

IconData _mapBranchIcon(String type) {
  switch (type) {
    case 'main':
      return Icons.location_city;
    case 'north':
      return Icons.business;
    case 'south':
      return Icons.apartment;
    default:
      return Icons.store;
  }
}

// Our New Classes Screen
class OurNewClassesScreen extends ConsumerStatefulWidget {
  const OurNewClassesScreen({super.key});

  @override
  ConsumerState<OurNewClassesScreen> createState() =>
      _OurNewClassesScreenState();
}

class _OurNewClassesScreenState extends ConsumerState<OurNewClassesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translate(LHome.newClassesTitle, locale)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchClasses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonListPage(itemCount: 6);
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(AppLocalizations.translate(LHome.noClasses, locale)));
          }
          final classes = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final cls = classes[index];
              final programName = cls['programs'] != null
                  ? (cls['programs'] as Map)['name'] as String? ?? ''
                  : '';
              final name =
                  '${programName.isNotEmpty ? '$programName - ' : ''}${cls['name'] as String? ?? ''}';
              final time = cls['year'] != null
                  ? cls['year'].toString()
                  : cls['grade'] as String? ?? '';
              final studentCount = cls['student_count'] as int? ?? 0;
              final seats = '$studentCount';
              final isActive = cls['active'] as bool? ?? false;
              final status = isActive
                  ? AppLocalizations.translate(LHome.statusOpen, locale)
                  : AppLocalizations.translate(LHome.statusClosed, locale);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.black.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: isActive ? Colors.black87 : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(time.isNotEmpty ? time : AppLocalizations.translate(LHome.scheduleTbd, locale),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 16),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.translate(LHome.seatsFmt, locale).replaceAll('%s', seats),
                              overflow: TextOverflow.ellipsis),
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

  Future<List<Map<String, dynamic>>> _fetchClasses() async {
    final supabase = Supabase.instance.client;
    try {
      final response =
          await supabase.from('classes').select('*, programs(name)');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
