import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:course_users/models/placement_test.dart';

class PlacementTestService {
  static final PlacementTestService _instance = PlacementTestService._internal();
  factory PlacementTestService() => _instance;
  PlacementTestService._internal();

  final Map<String, PlacementTest> _testCache = {};
  final Map<String, ProgressTracking> _progressCache = {};

  Future<List<PlacementTest>> getAvailableTests(String languageCode) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return _generateMockTests(languageCode);
    } catch (e) {
      debugPrint('Error getting placement tests: $e');
      return [];
    }
  }

  Future<PlacementTest?> getTestById(String testId) async {
    try {
      if (_testCache.containsKey(testId)) {
        return _testCache[testId];
      }
      await Future.delayed(const Duration(milliseconds: 300));
      final test = _generateMockTest(testId);
      if (test != null) {
        _testCache[testId] = test;
      }
      return test;
    } catch (e) {
      debugPrint('Error getting test by ID: $e');
      return null;
    }
  }

  Future<TestAttempt> startTestAttempt(String testId, String userId) async {
    try {
      final test = await getTestById(testId);
      if (test == null) {
        throw Exception('Test not found');
      }

      final attempt = TestAttempt(
        id: _generateId(),
        testId: testId,
        userId: userId,
        startedAt: DateTime.now(),
        timeSpent: Duration.zero,
        score: 0,
        maxScore: test.totalQuestions,
        percentage: 0.0,
        resultLevel: '',
        status: TestStatus.active,
        answers: [],
      );

      return attempt;
    } catch (e) {
      debugPrint('Error starting test attempt: $e');
      rethrow;
    }
  }

  Future<void> submitAnswer(String attemptId, QuestionAnswer answer) async {
    // Implementation would store the answer
    debugPrint('Submitting answer for attempt $attemptId');
  }

  Future<TestAttempt> completeTestAttempt(String attemptId) async {
    try {
      // Mock completion
      final attempt = TestAttempt(
        id: attemptId,
        testId: 'test_1',
        userId: 'user_1',
        startedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        completedAt: DateTime.now(),
        timeSpent: const Duration(minutes: 30),
        score: 35,
        maxScore: 50,
        percentage: 70.0,
        resultLevel: 'B1 (Intermediate)',
        status: TestStatus.completed,
        answers: [],
      );

      return attempt;
    } catch (e) {
      debugPrint('Error completing test attempt: $e');
      rethrow;
    }
  }

  Future<List<TestAttempt>> getUserAttempts(String userId, {String? testId}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return [];
    } catch (e) {
      debugPrint('Error getting user attempts: $e');
      return [];
    }
  }

  Future<ProgressTracking?> getProgressTracking(String userId, String languageCode) async {
    try {
      final cacheKey = 'progress_${userId}_$languageCode';
      if (_progressCache.containsKey(cacheKey)) {
        return _progressCache[cacheKey];
      }

      await Future.delayed(const Duration(milliseconds: 300));
      
      final progress = _generateMockProgress(userId, languageCode);
      if (progress != null) {
        _progressCache[cacheKey] = progress;
      }
      
      return progress;
    } catch (e) {
      debugPrint('Error getting progress tracking: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getTestAnalytics(String testId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'total_attempts': 150,
        'average_score': 75.5,
        'pass_rate': 0.68,
      };
    } catch (e) {
      debugPrint('Error getting test analytics: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getUserAnalytics(String userId, String languageCode) async {
    try {
      final progress = await getProgressTracking(userId, languageCode);
      if (progress == null) return {};

      return {
        'current_level': progress.currentLevel,
        'total_study_time': progress.totalStudyTime,
        'study_streak': progress.studyStreak,
        'completed_lessons': progress.completedLessons.length,
        'test_attempts': progress.testAttempts.length,
        'average_test_score': progress.testAverageScore,
      };
    } catch (e) {
      debugPrint('Error getting user analytics: $e');
      return {};
    }
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  List<PlacementTest> _generateMockTests(String languageCode) {
    return [
      PlacementTest(
        id: 'test_1',
        title: 'English Placement Test',
        description: 'Comprehensive assessment of your English language skills',
        type: TestType.placement,
        status: TestStatus.active,
        languageCode: languageCode,
        totalQuestions: 50,
        passingScore: 35,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        expiresAt: DateTime.now().add(const Duration(days: 90)),
      ),
      PlacementTest(
        id: 'test_2',
        title: 'Progress Check Test',
        description: 'Track your learning progress',
        type: TestType.progress,
        status: TestStatus.active,
        languageCode: languageCode,
        totalQuestions: 30,
        passingScore: 21,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }

  PlacementTest? _generateMockTest(String testId) {
    if (testId == 'test_1' || testId == 'test_2') {
      return _generateMockTests('en').firstWhere((test) => test.id == testId);
    }
    return null;
  }

  ProgressTracking? _generateMockProgress(String userId, String languageCode) {
    return ProgressTracking(
      id: 'progress_${userId}_$languageCode',
      userId: userId,
      languageCode: languageCode,
      currentLevel: 'B1 (Intermediate)',
      startedAt: DateTime.now().subtract(const Duration(days: 30)),
      lastActivityAt: DateTime.now().subtract(const Duration(hours: 2)),
      totalStudyTime: 1800,
      studyStreak: 5,
      completedLessons: ['lesson_1', 'lesson_2', 'lesson_3'],
      testAttempts: [],
    );
  }
}
