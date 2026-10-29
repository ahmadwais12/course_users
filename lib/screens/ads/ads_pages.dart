import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:course_users/widgets/adaptive/adaptive_widgets.dart';

class AdsHubScreen extends StatefulWidget {
  const AdsHubScreen({super.key});

  @override
  State<AdsHubScreen> createState() => _AdsHubScreenState();
}

class _AdsHubScreenState extends State<AdsHubScreen> {
  List<Map<String, dynamic>> _campaigns = [];
  List<Map<String, dynamic>> _courseAds = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sb = Supabase.instance.client;
      final campaigns = await sb
          .from('ads_campaigns')
          .select()
          .order('created_at', ascending: false)
          .limit(50);
      final courseAds = await sb
          .from('course_ads')
          .select()
          .order('created_at', ascending: false)
          .limit(50);
      if (!mounted) return;
      setState(() {
        _campaigns = List<Map<String, dynamic>>.from(campaigns as List);
        _courseAds = List<Map<String, dynamic>>.from(courseAds as List);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'Ads Hub',
      actions: [
        IconButton(
          icon: Icon(
            PlatformAdaptive.isApple ? CupertinoIcons.refresh : Icons.refresh,
          ),
          onPressed: _load,
        ),
      ],
      body: AdaptiveRefresh(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: AdaptiveProgress());
    if (_error != null) {
      return ListView(
        physics: PlatformAdaptive.scrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
          Center(child: FilledButton(onPressed: _load, child: const Text('Retry'))),
        ],
      );
    }

    return ListView(
      physics: PlatformAdaptive.scrollPhysics(
        const AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.all(16),
      children: [
        Text('Campaigns', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_campaigns.isEmpty)
          const Text('No campaigns yet.')
        else
          ..._campaigns.map(
            (c) => Card(
              child: ListTile(
                leading: const Icon(Icons.campaign_outlined),
                title: Text(c['name']?.toString() ?? 'Campaign'),
                subtitle: Text(
                  '${c['platform'] ?? '-'} · ${c['status'] ?? '-'}',
                ),
                trailing: Text('${c['budget'] ?? 0}'),
              ),
            ),
          ),
        const SizedBox(height: 24),
        Text('Course Ads', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_courseAds.isEmpty)
          const Text('No course ads yet.')
        else
          ..._courseAds.map(
            (a) => Card(
              child: ListTile(
                leading: const Icon(Icons.school_outlined),
                title: Text(a['title']?.toString() ?? 'Course ad'),
                subtitle: Text(a['description']?.toString() ?? ''),
                trailing: Icon(
                  (a['is_active'] == true)
                      ? Icons.check_circle
                      : Icons.pause_circle_outline,
                  color: (a['is_active'] == true) ? Colors.green : Colors.grey,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
