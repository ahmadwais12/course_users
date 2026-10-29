import 'package:course_users/models/attendance.dart';

class GradeRepository {
  final List<Grade> _cache = [];

  Future<List<Grade>> getAll() async => List.from(_cache);
  Future<List<Grade>> getByStudent(String studentId) async => _cache.where((g) => g.studentId == studentId).toList();
  
  Future<void> create(Grade grade) async {
    _cache.add(grade);
  }

  Future<void> update(Grade grade) async {
    final index = _cache.indexWhere((g) => g.id == grade.id);
    if (index != -1) _cache[index] = grade;
  }

  Future<void> delete(String id) async {
    _cache.removeWhere((g) => g.id == id);
  }
}
