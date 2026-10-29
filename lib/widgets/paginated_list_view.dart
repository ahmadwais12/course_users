import 'package:flutter/material.dart';
import 'package:course_users/components/empty_state.dart';
import 'package:course_users/theme.dart';

/// Reusable infinite-scroll paginated list.
///
/// Handles:
/// - initial skeleton shimmer loading
/// - lazy fetch of pages (default 12 per page)
/// - circular progress footer while loading more
/// - empty state
/// - error state with retry
class PaginatedListView<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int pageSize) fetcher;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, List<T> items)? header;
  final Widget Function(BuildContext context, List<T> items)? empty;
  final Widget Function(BuildContext context)? skeleton;
  final Widget Function(BuildContext context, Object error, VoidCallback retry)?
      errorBuilder;
  final int pageSize;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry itemPadding;
  final double triggerDistance;

  const PaginatedListView({
    super.key,
    required this.fetcher,
    required this.itemBuilder,
    this.header,
    this.empty,
    this.skeleton,
    this.errorBuilder,
    this.pageSize = 12,
    this.padding = const EdgeInsets.all(16),
    this.itemPadding = const EdgeInsets.only(bottom: 12),
    this.triggerDistance = 200,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _scrollController = ScrollController();
  final List<T> _items = [];
  int _currentPage = 0;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isInitialLoading) return;
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - widget.triggerDistance) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isInitialLoading = true;
      _error = null;
    });
    try {
      final page = await widget.fetcher(0, widget.pageSize);
      if (!mounted) return;
      setState(() {
        _items.addAll(page);
        _hasMore = page.length >= widget.pageSize;
        _currentPage = 0;
        _isInitialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    try {
      final page = await widget.fetcher(_currentPage + 1, widget.pageSize);
      if (!mounted) return;
      setState(() {
        _items.addAll(page);
        _hasMore = page.length >= widget.pageSize;
        _currentPage++;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _retry() async {
    setState(() {
      _items.clear();
      _currentPage = 0;
      _hasMore = true;
    });
    await _loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return widget.skeleton?.call(context) ??
          const SkeletonListPage();
    }

    if (_error != null) {
      return widget.errorBuilder?.call(context, _error!, _retry) ??
          _DefaultError(error: _error!, onRetry: _retry);
    }

    if (_items.isEmpty) {
      return widget.empty?.call(context, _items) ??
          const Center(child: AppEmptyState(message: 'No data available'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const _LoadingMoreFooter();
        }
        final item = _items[index];
        return Padding(
          padding: widget.itemPadding,
          child: widget.itemBuilder(context, item, index),
        );
      },
    );
  }
}

/// Reusable infinite-scroll paginated grid.
///
/// Handles:
/// - initial skeleton shimmer loading
/// - lazy fetch of pages (default 12 per page)
/// - circular progress footer while loading more
/// - empty state
/// - error state with retry
class PaginatedGridView<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int pageSize) fetcher;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, List<T> items)? empty;
  final Widget Function(BuildContext context)? skeleton;
  final Widget Function(BuildContext context, Object error, VoidCallback retry)?
      errorBuilder;
  final int pageSize;
  final EdgeInsetsGeometry padding;
  final SliverGridDelegate gridDelegate;
  final double triggerDistance;

  const PaginatedGridView({
    super.key,
    required this.fetcher,
    required this.itemBuilder,
    this.empty,
    this.skeleton,
    this.errorBuilder,
    this.pageSize = 12,
    this.padding = const EdgeInsets.all(16),
    this.gridDelegate = const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 420,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
    ),
    this.triggerDistance = 200,
  });

  @override
  State<PaginatedGridView<T>> createState() => _PaginatedGridViewState<T>();
}

class _PaginatedGridViewState<T> extends State<PaginatedGridView<T>> {
  final ScrollController _scrollController = ScrollController();
  final List<T> _items = [];
  int _currentPage = 0;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isInitialLoading) return;
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - widget.triggerDistance) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isInitialLoading = true;
      _error = null;
    });
    try {
      final page = await widget.fetcher(0, widget.pageSize);
      if (!mounted) return;
      setState(() {
        _items.addAll(page);
        _hasMore = page.length >= widget.pageSize;
        _currentPage = 0;
        _isInitialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    try {
      final page = await widget.fetcher(_currentPage + 1, widget.pageSize);
      if (!mounted) return;
      setState(() {
        _items.addAll(page);
        _hasMore = page.length >= widget.pageSize;
        _currentPage++;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _retry() async {
    setState(() {
      _items.clear();
      _currentPage = 0;
      _hasMore = true;
    });
    await _loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return widget.skeleton?.call(context) ?? const SkeletonGridPage();
    }

    if (_error != null) {
      return widget.errorBuilder?.call(context, _error!, _retry) ??
          _DefaultError(error: _error!, onRetry: _retry);
    }

    if (_items.isEmpty) {
      return widget.empty?.call(context, _items) ??
          const Center(child: AppEmptyState(message: 'No data available'));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: widget.padding,
      gridDelegate: widget.gridDelegate,
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const _LoadingMoreFooter();
        }
        return widget.itemBuilder(context, _items[index], index);
      },
    );
  }
}

/// Footer shown while fetching the next page.
class _LoadingMoreFooter extends StatelessWidget {
  const _LoadingMoreFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _DefaultError extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _DefaultError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            const Text('Something went wrong',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              '$error',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton shimmer for a list page.
class SkeletonListPage extends StatelessWidget {
  final int itemCount;

  const SkeletonListPage({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            _SkBlock(width: 50, height: 50, radius: 25, theme: theme),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkBlock(
                      width: double.infinity, height: 16, theme: theme),
                  const SizedBox(height: 8),
                  _SkBlock(width: 140, height: 12, theme: theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton shimmer for a grid page.
class SkeletonGridPage extends StatelessWidget {
  final int itemCount;

  const SkeletonGridPage({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 420,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => Container(
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkBlock(width: 44, height: 44, radius: 12, theme: theme),
            const SizedBox(height: 14),
            _SkBlock(width: 120, height: 16, theme: theme),
            const SizedBox(height: 8),
            _SkBlock(width: 90, height: 12, theme: theme),
            const Spacer(),
            _SkBlock(width: double.infinity, height: 36, radius: 10, theme: theme),
          ],
        ),
      ),
    );
  }
}

class _SkBlock extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final ThemeData theme;

  const _SkBlock({
    required this.width,
    required this.height,
    required this.theme,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.dividerColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
