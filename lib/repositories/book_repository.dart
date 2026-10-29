import 'package:course_users/models/book.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Book>> getAll() async {
    final data = await _supabase
        .from('books')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((json) => Book.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<void> create(Book book) async {
    await _supabase.from('books').insert(_toRow(book));
  }

  Future<void> update(Book book) async {
    await _supabase.from('books').update(_toRow(book)).eq('id', book.id);
  }

  Future<void> delete(String id) async {
    await _supabase.from('books').delete().eq('id', id);
  }

  Map<String, dynamic> _toRow(Book book) => {
        'title': book.title,
        'description': book.description,
        'selling_price': book.price,
        'available_copies': book.stock,
        if (book.isbn != null) 'isbn': book.isbn,
      };
}
