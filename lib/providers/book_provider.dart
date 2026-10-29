import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:course_users/models/book.dart';
import 'package:course_users/repositories/book_repository.dart';

final bookRepositoryProvider = Provider((ref) => BookRepository());

final booksNotifierProvider = StateNotifierProvider<BooksNotifier, AsyncValue<List<Book>>>((ref) {
  return BooksNotifier(ref.watch(bookRepositoryProvider));
});

class BooksNotifier extends StateNotifier<AsyncValue<List<Book>>> {
  final BookRepository _repository;
  
  BooksNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadBooks();
  }
  
  Future<void> loadBooks() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAll());
  }
  
  Future<void> addBook(Book book) async {
    await _repository.create(book);
    await loadBooks();
  }
}
