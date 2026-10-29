import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:course_users/widgets/adaptive/adaptive_widgets.dart';

/// Shared adaptive list page for student lifestyle modules.
class StudentLifestylePage extends StatefulWidget {
  final String title;
  final String tableName;
  final IconData icon;
  final List<String> fields;
  final Color accent;

  const StudentLifestylePage({
    super.key,
    required this.title,
    required this.tableName,
    required this.icon,
    this.fields = const ['title', 'name', 'description', 'status'],
    this.accent = const Color(0xFF0EA5E9),
  });

  @override
  State<StudentLifestylePage> createState() => _StudentLifestylePageState();
}

class _StudentLifestylePageState extends State<StudentLifestylePage> {
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
          .from(widget.tableName)
          .select()
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

  String _titleOf(Map<String, dynamic> row) {
    for (final f in widget.fields) {
      final v = row[f];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return widget.title;
  }

  String _subtitleOf(Map<String, dynamic> row) {
    final parts = <String>[];
    for (final f in widget.fields.skip(1).take(3)) {
      final v = row[f];
      if (v != null && '$v'.trim().isNotEmpty) parts.add('$v');
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: widget.title,
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
        padding: const EdgeInsets.all(24),
        children: [
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Center(child: FilledButton(onPressed: _load, child: const Text('Retry'))),
        ],
      );
    }
    if (_rows.isEmpty) {
      return ListView(
        physics: PlatformAdaptive.scrollPhysics(
          const AlwaysScrollableScrollPhysics(),
        ),
        children: [
          const SizedBox(height: 80),
          Icon(widget.icon, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text('No ${widget.title.toLowerCase()} yet', textAlign: TextAlign.center),
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
        final row = _rows[i];
        return ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.35),
          leading: CircleAvatar(
            backgroundColor: widget.accent.withValues(alpha: 0.15),
            child: Icon(widget.icon, color: widget.accent),
          ),
          title: Text(_titleOf(row)),
          subtitle: Text(_subtitleOf(row)),
        );
      },
    );
  }
}
