import '../config/page_registry.dart';

/// Panel-specific page configuration for bottom navigation "More" menu.
class PanelPagesConfig {
  /// Get pages for a specific panel/role.
  static List<PageRegistry> getPagesForPanel(String role) {
    switch (role) {
      case 'student':
        return _getStudentPages();
      case 'parent':
        return _getParentPages();
      default:
        return _getDefaultPages();
    }
  }

  /// Student pages mapped to Supabase schema tables.
  static List<PageRegistry> _getStudentPages() {
    return _safePages([
      'student_courses',
      'student_assignments',
      'student_attendance',
      'student_grades',
      'student_schedule',
      'student_resources',
      'exams',
      'results',
      'certificates',
      'library',
      'digital_library',
      'lms',
      'fee_details',
      'student_documents',
      'student_leaves',
      'academic_history',
      'feedback',
      'student_notifications',
      'notification_preferences',
      'help_support',
      'profile',
      'settings',
    ]);
  }

  /// Parent pages mapped to Supabase schema tables.
  static List<PageRegistry> _getParentPages() {
    return _safePages([
      'children_profile',
      'children_attendance',
      'report_cards',
      'performance_tracking',
      'fee_payment_history',
      'invoices',
      'payments',
      'parent_messaging',
      'messages',
      'calendar',
      'events',
      'notice_board',
      'parent_leave_applications',
      'parent_documents',
      'parent_complaints',
      'parent_feedback',
      'transport_tracking',
      'health_records',
      'emergency_contacts',
      'parent_settings',
      'notifications',
      'chat',
      'profile',
    ]);
  }

  /// Default fallback pages.
  static List<PageRegistry> _getDefaultPages() {
    return _safePages([
      'profile',
      'settings',
      'notifications',
      'messages',
      'chat',
      'help_support',
      'about_emis',
    ]);
  }

  /// Common pages available to all panels.
  static List<PageRegistry> getCommonPages() {
    return _safePages([
      'profile',
      'settings',
      'notifications',
      'messages',
      'chat',
      'help_support',
      'about_emis',
    ]);
  }

  static List<PageRegistry> _safePages(List<String> ids) {
    return ids
        .map(AppPageRegistry.getPageById)
        .whereType<PageRegistry>()
        .toList();
  }
}
