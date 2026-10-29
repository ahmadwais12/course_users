import 'package:course_users/models/teacher.dart';

class PayrollRepository {
  final List<Payroll> _cache = [];

  Future<List<Payroll>> getAll() async => List.from(_cache);
  Future<List<Payroll>> getByTeacher(String teacherId) async => _cache.where((p) => p.teacherId == teacherId).toList();
  
  Future<void> create(Payroll payroll) async {
    _cache.add(payroll);
  }

  Future<void> update(Payroll payroll) async {
    final index = _cache.indexWhere((p) => p.id == payroll.id);
    if (index != -1) _cache[index] = payroll;
  }

  Future<void> delete(String id) async {
    _cache.removeWhere((p) => p.id == id);
  }
}
