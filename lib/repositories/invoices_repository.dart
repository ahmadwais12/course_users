import 'package:course_users/repositories/base_repository.dart';

class InvoicesRepository extends BaseRepository {
  InvoicesRepository() : super('invoices');

  Future<List<Map<String, dynamic>>> getAllInvoices({String? studentId}) async {
    if (studentId != null) {
      return await getAll(
          filters: {'student_id': studentId},
          orderBy: 'due_date',
          ascending: false);
    }
    return await getAll(orderBy: 'due_date', ascending: false);
  }

  Stream<List<Map<String, dynamic>>> streamInvoices(
      {String? studentId}) async* {
    final filters = studentId != null ? {'student_id': studentId} : null;
    await for (final data in stream(filters: filters)) {
      yield data;
    }
  }

  @override
  Future<void> create(Map<String, dynamic> data) async {
    data['created_at'] = DateTime.now().toIso8601String();
    await super.create(data);
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    data['updated_at'] = DateTime.now().toIso8601String();
    await super.update(id, data);
  }
}
