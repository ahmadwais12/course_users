import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:course_users/repositories/home_repository.dart';

final heroSectionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = HeroSectionRepository();
  return await repository.getActiveHeroSections();
});

final featuresProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = FeatureRepository();
  return await repository.getActiveFeatures();
});

final statsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = StatRepository();
  return await repository.getActiveStats();
});

final testimonialsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = TestimonialRepository();
  return await repository.getActiveTestimonials();
});

final homeStatsProvider = FutureProvider<HomeStats>((ref) async {
  final supabase = Supabase.instance.client;

  try {
    // Fetch counts from database
    final studentsResponse =
        await supabase.from('students').select('id');
    final teachersResponse =
        await supabase.from('users').select('id').eq('role', 'teacher');
    final classesResponse = await supabase.from('classes').select('id');
    final tenantsResponse =
        await supabase.from('tenants').select('id').eq('is_active', true);

    return HomeStats(
      totalStudents: studentsResponse.length,
      totalTeachers: teachersResponse.length,
      totalClasses: classesResponse.length,
      totalSchools: tenantsResponse.length,
      pendingPayments: 0,
    );
  } catch (e) {
    // Return default values if database fetch fails
    return HomeStats(
      totalStudents: 0,
      totalTeachers: 0,
      totalClasses: 0,
      totalSchools: 0,
      pendingPayments: 0,
    );
  }
});

// Provider for active branches/schools
final activeBranchesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase
        .from('branches')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(10);

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    return [];
  }
});

// Provider for recent activity
final recentActivityProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;

  try {
    // Get recent students enrolled
    final recentStudents = await supabase
        .from('students')
        .select('*, users(full_name, avatar_url)')
        .order('created_at', ascending: false)
        .limit(5);

    return List<Map<String, dynamic>>.from(recentStudents);
  } catch (e) {
    return [];
  }
});

// Provider for upcoming events
final upcomingEventsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase
        .from('events')
        .select()
        .gte('start_date', DateTime.now().toIso8601String())
        .order('start_date', ascending: true)
        .limit(5);

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    return [];
  }
});

final topStudentsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  try {
    final response = await supabase
        .from('students')
        .select('id, full_name, student_code, photo_url, average_grade, attendance_percentage')
        .eq('status', 'active')
        .order('average_grade', ascending: false)
        .limit(10);
    return List<Map<String, dynamic>>.from(response)
      ..removeWhere((s) => s['average_grade'] == null);
  } catch (e) {
    return [];
  }
});

final teachersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  try {
    final response = await supabase
        .from('teachers')
        .select('id, full_name, email, phone, specialization, qualification, experience_years, photo_url')
        .order('full_name', ascending: true)
        .limit(10);
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    return [];
  }
});

class HomeStats {
  final int totalStudents;
  final int totalTeachers;
  final int totalClasses;
  final int totalSchools;
  final double pendingPayments;

  HomeStats({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalClasses,
    required this.totalSchools,
    required this.pendingPayments,
  });
}
