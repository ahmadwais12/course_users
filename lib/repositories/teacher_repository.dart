import 'package:course_users/models/teacher.dart';

class TeacherRepository {
  final List<Teacher> _cache = [];

  Future<List<Teacher>> getAll() async => List.from(_cache);
  Future<Teacher?> getById(String id) async => _cache.cast<Teacher?>().firstWhere((t) => t?.id == id, orElse: () => null);
  
  Future<void> create(Teacher teacher) async {
    _cache.add(teacher);
  }

  Future<void> update(Teacher teacher) async {
    final index = _cache.indexWhere((t) => t.id == teacher.id);
    if (index != -1) _cache[index] = teacher;
  }

  Future<void> delete(String id) async {
    _cache.removeWhere((t) => t.id == id);
  }
}
