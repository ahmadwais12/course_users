import 'package:course_users/models/lms_content.dart';

class LMSRepository {
  final List<LMSContent> _cache = [];

  Future<List<LMSContent>> getAll() async => List.from(_cache);
  Future<List<LMSContent>> getByClass(String classId) async => 
    _cache.where((c) => c.classId == classId && c.isPublished).toList()..sort((a, b) => a.order.compareTo(b.order));
  
  Future<void> create(LMSContent content) async {
    _cache.add(content);
  }

  Future<void> update(LMSContent content) async {
    final index = _cache.indexWhere((c) => c.id == content.id);
    if (index != -1) _cache[index] = content;
  }

  Future<void> delete(String id) async {
    _cache.removeWhere((c) => c.id == id);
  }
}
