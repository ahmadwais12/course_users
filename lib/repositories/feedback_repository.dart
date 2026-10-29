import 'package:course_users/models/lms_content.dart' as models;

class FeedbackRepository {
  final List<models.Feedback> _cache = [];

  Future<List<models.Feedback>> getAll() async => List.from(_cache);
  Future<List<models.Feedback>> getByStudent(String studentId) async =>
      _cache.where((f) => f.studentId == studentId).toList();

  Future<void> create(models.Feedback feedback) async {
    _cache.add(feedback);
  }

  Future<void> update(models.Feedback feedback) async {
    final index = _cache.indexWhere((f) => f.id == feedback.id);
    if (index != -1) _cache[index] = feedback;
  }

  Future<void> delete(String id) async {
    _cache.removeWhere((f) => f.id == id);
  }
}
