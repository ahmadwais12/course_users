import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:course_users/widgets/modern_ui.dart';
import 'package:course_users/widgets/paginated_list_view.dart';
import 'package:course_users/l10n/app_localizations.dart';
import 'package:course_users/l10n/locale_keys.dart';

class ApplyOnlineScreen extends ConsumerStatefulWidget {
  const ApplyOnlineScreen({super.key});

  @override
  ConsumerState<ApplyOnlineScreen> createState() => _ApplyOnlineScreenState();
}

class _ApplyOnlineScreenState extends ConsumerState<ApplyOnlineScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _courseCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _courseCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = ref.read(localeProvider);
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.translate(LHome.pleaseFillRequired, l))),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await Supabase.instance.client.from('leads').insert({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'interested_program': _courseCtrl.text.trim(),
        'notes': _messageCtrl.text.trim(),
        'source': 'Apply Online',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.translate(LHome.applicationSubmitted, l))),
      );
      _nameCtrl.clear();
      _emailCtrl.clear();
      _phoneCtrl.clear();
      _courseCtrl.clear();
      _messageCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.translate(L.error_, l)}: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: ModernAppBar(title: AppLocalizations.translate(LHome.applyOnlineTitle, locale), hasGradient: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.translate(LHome.startYourJourney, locale),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.translate(LHome.fillDetails, locale),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.translate(L.fullName, locale),
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: AppLocalizations.translate(L.email, locale),
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: AppLocalizations.translate(L.phoneNumber, locale),
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _courseCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.translate(LHome.courseInterested, locale),
                prefixIcon: const Icon(Icons.school_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: AppLocalizations.translate(LHome.messageOptional, locale),
                prefixIcon: const Icon(Icons.message_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(AppLocalizations.translate(LHome.submitApplication, locale),
                        style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RequestCallScreen extends ConsumerStatefulWidget {
  const RequestCallScreen({super.key});

  @override
  ConsumerState<RequestCallScreen> createState() => _RequestCallScreenState();
}

class _RequestCallScreenState extends ConsumerState<RequestCallScreen> {
  final _phoneCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = ref.read(localeProvider);
    if (_phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.translate(LHome.pleaseEnterPhone, l))),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await Supabase.instance.client.from('leads').insert({
        'phone': _phoneCtrl.text.trim(),
        'notes': _timeCtrl.text.trim(),
        'source': 'Call Request',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.translate(LHome.wellCallShortly, l))),
      );
      _phoneCtrl.clear();
      _timeCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.translate(L.error_, l)}: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: ModernAppBar(title: AppLocalizations.translate(LHome.requestCallTitle, locale), hasGradient: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.phone_callback_rounded,
                size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.translate(LHome.weCallYouBack, locale),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.translate(LHome.leaveNumber, locale),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: AppLocalizations.translate(L.phoneNumber, locale),
                prefixIcon: const Icon(Icons.phone_outlined),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: AppLocalizations.translate(LHome.bestTimeToCall, locale),
                hintText: AppLocalizations.translate(LHome.timeHint, locale),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: const Icon(Icons.phone_callback_rounded),
                label: _submitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(AppLocalizations.translate(LHome.requestCallBtn, locale), style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WhyOurCourseScreen extends ConsumerStatefulWidget {
  const WhyOurCourseScreen({super.key});

  @override
  ConsumerState<WhyOurCourseScreen> createState() => _WhyOurCourseScreenState();
}

class _WhyOurCourseScreenState extends ConsumerState<WhyOurCourseScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: ModernAppBar(title: AppLocalizations.translate(LHome.whyOurCourseTitle, locale), hasGradient: true),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchReasons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonListPage(itemCount: 6);
          }
          final reasons = snapshot.data ?? [];
          if (reasons.isEmpty) {
            return Center(child: Text(AppLocalizations.translate(LHome.noInfo, locale)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: reasons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final r = reasons[index];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _mapSectionIcon(r['icon_name'] as String? ?? ''),
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r['title'] as String? ?? '',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r['description'] as String? ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
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

  Future<List<Map<String, dynamic>>> _fetchReasons() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('home_features')
          .select()
          .eq('is_active', true)
          .order('display_order');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}

IconData _mapSectionIcon(String iconName) {
  switch (iconName) {
    case 'group':
      return Icons.group_rounded;
    case 'schedule':
      return Icons.schedule_rounded;
    case 'verified':
      return Icons.verified_rounded;
    case 'people':
      return Icons.people_rounded;
    case 'trending_up':
      return Icons.trending_up_rounded;
    case 'support':
      return Icons.support_agent_rounded;
    default:
      return Icons.star_rounded;
  }
}

class OurReviewsScreen extends ConsumerStatefulWidget {
  const OurReviewsScreen({super.key});

  @override
  ConsumerState<OurReviewsScreen> createState() => _OurReviewsScreenState();
}

class _OurReviewsScreenState extends ConsumerState<OurReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: ModernAppBar(title: AppLocalizations.translate(LHome.ourReviewsTitle, locale), hasGradient: true),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonListPage(itemCount: 6);
          }
          final reviews = snapshot.data ?? [];
          if (reviews.isEmpty) {
            return Center(child: Text(AppLocalizations.translate(LHome.noReviewsYet, locale)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final r = reviews[index];
              final rating = (r['rating'] as num?)?.toInt() ?? 5;
              final author = r['author'] as String? ?? '';
              final authorTitle = r['author_title'] as String? ?? '';
              final quote = r['quote'] as String? ?? '';

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            child: Text(author.isNotEmpty ? author[0] : '?'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  author,
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (authorTitle.isNotEmpty)
                                  Text(
                                    authorTitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < rating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 18,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (quote.isNotEmpty)
                        Text(
                          '"$quote"',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
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

  Future<List<Map<String, dynamic>>> _fetchReviews() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('home_testimonials')
          .select()
          .eq('is_active', true)
          .order('display_order');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}

class ContactCourseScreen extends ConsumerStatefulWidget {
  const ContactCourseScreen({super.key});

  @override
  ConsumerState<ContactCourseScreen> createState() =>
      _ContactCourseScreenState();
}

class _ContactCourseScreenState extends ConsumerState<ContactCourseScreen> {
  String _phone = '';
  String _email = '';
  String _address = '';
  String _hours = '';
  final _messageCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final l = ref.read(localeProvider);
    _phone = AppLocalizations.translate(LHome.contactDefaultPhone, l);
    _email = AppLocalizations.translate(LHome.contactDefaultEmail, l);
    _address = AppLocalizations.translate(LHome.contactDefaultAddress, l);
    _hours = AppLocalizations.translate(LHome.contactDefaultHours, l);
    _loadContactInfo();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadContactInfo() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('tenants')
          .select('phone, email, address, working_hours')
          .limit(1)
          .single();
      if (mounted) {
        setState(() {
          _phone = (response['phone'] as String?) ?? _phone;
          _email = (response['email'] as String?) ?? _email;
          _address = (response['address'] as String?) ?? _address;
          _hours = (response['working_hours'] as String?) ?? _hours;
        });
      }
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final l = ref.read(localeProvider);
    if (_messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.translate(LHome.pleaseEnterMessage, l))),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await Supabase.instance.client.from('leads').insert({
        'notes': _messageCtrl.text.trim(),
        'source': 'Contact Message',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.translate(LHome.messageSent, l))),
      );
      _messageCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.translate(L.error_, l)}: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: ModernAppBar(title: AppLocalizations.translate(LHome.contactCourseTitle, locale), hasGradient: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.translate(LHome.getInTouch, locale),
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(AppLocalizations.translate(LHome.weLoveToHear, locale),
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 32),
            _ContactTile(
                icon: Icons.location_on_rounded,
                title: AppLocalizations.translate(LHome.address, locale),
                subtitle: _address),
            _ContactTile(
                icon: Icons.phone_rounded, title: AppLocalizations.translate(LHome.phone, locale), subtitle: _phone),
            _ContactTile(
                icon: Icons.email_rounded, title: AppLocalizations.translate(LHome.email, locale), subtitle: _email),
            _ContactTile(
                icon: Icons.access_time_rounded,
                title: AppLocalizations.translate(LHome.officeHours, locale),
                subtitle: _hours),
            const SizedBox(height: 32),
            TextField(
              controller: _messageCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.translate(LHome.yourMessage, locale),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _submitting ? null : _sendMessage,
                child: _submitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(AppLocalizations.translate(LHome.sendMessage, locale), style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ContactTile(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
