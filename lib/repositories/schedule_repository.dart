import 'package:course_users/repositories/base_repository.dart';

class ScheduleRepository extends BaseRepository {
  ScheduleRepository() : super('student_schedules');

  Future<List<Map<String, dynamic>>> getAllSchedule({String? courseId}) async {
    if (courseId != null) {
      return await getAll(
        filters: {'course_id': courseId},
        orderBy: 'day_of_week',
        ascending: true,
      );
    }
    return await getAll(orderBy: 'day_of_week', ascending: true);
  }

  Stream<List<Map<String, dynamic>>> streamSchedule({String? courseId}) async* {
    final filters = courseId != null ? {'course_id': courseId} : null;
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
