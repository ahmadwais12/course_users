import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:course_users/widgets/adaptive/adaptive_widgets.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  List<Map<String, dynamic>> _rows = [];
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
      final data = await Supabase.instance.client
          .from('programs')
          .select('id, name, code, description, status, created_at')
          .order('created_at', ascending: false)
          .limit(100);
      if (!mounted) return;
      setState(() {
        _rows = List<Map<String, dynamic>>.from(data as List);
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
      title: 'Programs',
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
          Text(_error!, textAlign: TextAlign.center),
          Center(child: FilledButton(onPressed: _load, child: const Text('Retry'))),
        ],
      );
    }
    if (_rows.isEmpty) {
      return ListView(
        physics: PlatformAdaptive.scrollPhysics(
          const AlwaysScrollableScrollPhysics(),
        ),
        children: const [
          SizedBox(height: 80),
          Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text('No programs yet', textAlign: TextAlign.center),
        ],
      );
    }
    return ListView.separated(
      physics: PlatformAdaptive.scrollPhysics(
        const AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.all(16),
      itemCount: _rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final p = _rows[i];
        return ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: Theme.of(context).colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.35),
          leading: CircleAvatar(
            child: Text(
              (() {
                final n = p['name']?.toString() ?? 'P';
                return n.isNotEmpty ? n[0].toUpperCase() : 'P';
              })(),
            ),
          ),
          title: Text(p['name']?.toString() ?? 'Program'),
          subtitle: Text(
            [
              if (p['code'] != null) p['code'].toString(),
              if (p['status'] != null) p['status'].toString(),
            ].join(' · '),
          ),
        );
      },
    );
  }
}
