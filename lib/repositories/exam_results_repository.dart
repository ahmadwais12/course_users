import 'package:course_users/repositories/base_repository.dart';

class ExamResultsRepository extends BaseRepository {
  ExamResultsRepository() : super('exam_results');

  Future<List<Map<String, dynamic>>> getAllExamResults(
      {String? classId}) async {
    if (classId != null) {
      return await getAll(
        filters: {'class_id': classId},
        orderBy: 'exam_date',
        ascending: false,
      );
    }
    return await getAll(orderBy: 'exam_date', ascending: false);
  }

  Stream<List<Map<String, dynamic>>> streamExamResults(
      {String? classId}) async* {
    final filters = classId != null ? {'class_id': classId} : null;
    await for (final data in stream(filters: filters)) {
      yield data;
    }
  }

  @override
  Future<void> create(Map<String, dynamic> data) async {
    data['created_at'] = DateTime.now().toIso8601String();
    await super.create(data);
  }
}
