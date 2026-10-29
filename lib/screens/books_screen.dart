import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:course_users/models/book.dart';
import 'package:course_users/providers/book_provider.dart';
import 'package:course_users/theme.dart';
import 'package:course_users/widgets/skeleton_loader.dart';

class BooksScreen extends ConsumerWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Books')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.menu_book_rounded),
        label: const Text('Add Book'),
      ),
      body: Padding(
        padding: AppSpacing.paddingLg,
        child: booksAsync.when(
          data: (books) => books.isEmpty
              ? Center(
                  child: Text('No books found',
                      style: Theme.of(context).textTheme.bodyLarge))
              : ListView.separated(
                  itemCount: books.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) =>
                      _BookCard(book: books[index]),
                ),
          loading: () => const ListSkeleton(itemCount: 6),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final titleCtl = TextEditingController();
    final priceCtl = TextEditingController(text: '500');
    final stockCtl = TextEditingController(text: '50');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Book'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleCtl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: priceCtl,
                  decoration: const InputDecoration(
                      labelText: 'Price', prefixText: 'PKR '),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: stockCtl,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final now = DateTime.now();
              final book = Book(
                id: 'book_${now.millisecondsSinceEpoch}',
                programId: 'prog_default',
                title: titleCtl.text.trim(),
                price: double.parse(priceCtl.text),
                stock: int.parse(stockCtl.text),
                description: titleCtl.text.trim(),
                createdAt: now,
              );
              ref.read(booksNotifierProvider.notifier).addBook(book);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(child: Icon(Icons.menu_book)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, style: theme.textTheme.titleLarge),
                Text(
                    'PKR ${book.price.toStringAsFixed(0)} • Stock: ${book.stock}',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
