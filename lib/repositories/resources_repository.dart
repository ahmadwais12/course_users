import 'package:course_users/repositories/base_repository.dart';

class ResourcesRepository extends BaseRepository {
  ResourcesRepository() : super('course_resources');

  Future<List<Map<String, dynamic>>> getAllResources({String? courseId}) async {
    if (courseId != null) {
      return await getAll(
        filters: {'course_id': courseId},
        orderBy: 'created_at',
        ascending: false,
      );
    }
    return await getAll(orderBy: 'created_at', ascending: false);
  }

  Stream<List<Map<String, dynamic>>> streamResources({String? courseId}) async* {
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
