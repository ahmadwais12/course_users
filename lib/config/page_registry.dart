import 'package:flutter/material.dart';
import '../screens/home_page.dart';
import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/our_story_screen.dart';
import '../screens/english_test_screen.dart';
import '../screens/attendance_screen.dart';
import '../screens/books_screen.dart';
import '../screens/payments_screen.dart';
import '../screens/students_screen.dart';
import '../screens/mobile_home.dart';
import '../screens/notifications_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/schema_pages.dart';
import '../screens/finance/fees_portal_screen.dart';


// Student screens
import '../screens/student/student_screens.dart';

// Parent screens
import '../screens/parent/parent_screens.dart';


// Page model for registry
class PageRegistry {
  final String id;
  final String name;
  final String description;
  final String category;
  final String role; // 'all', 'student', 'parent'
  final WidgetBuilder builder;
  final IconData icon;
  final bool isActive;

  PageRegistry({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.role,
    required this.builder,
    required this.icon,
    this.isActive = true,
  });
}

  /// Centralized page registry for course_users.
/// Pages map to Supabase schema tables where applicable.
class AppPageRegistry {
  static final List<PageRegistry> _pages = [
    // ── Authentication ──
    PageRegistry(
      id: 'splash',
      name: 'Splash Screen',
      description: 'App splash screen',
      category: 'Authentication',
      role: 'all',
      icon: Icons.play_arrow,
      builder: (context) => const SplashScreen(),
    ),
    PageRegistry(
      id: 'onboarding',
      name: 'Onboarding',
      description: 'User onboarding flow',
      category: 'Authentication',
      role: 'all',
      icon: Icons.swipe,
      builder: (context) => const OnboardingScreen(),
    ),
    PageRegistry(
      id: 'login',
      name: 'Login',
      description: 'User login screen',
      category: 'Authentication',
      role: 'all',
      icon: Icons.login,
      builder: (context) => const LoginScreen(),
    ),
    PageRegistry(
      id: 'signup',
      name: 'Sign Up',
      description: 'User registration screen',
      category: 'Authentication',
      role: 'all',
      icon: Icons.app_registration,
      builder: (context) => const SignupScreen(),
    ),
    PageRegistry(
      id: 'forgot_password',
      name: 'Forgot Password',
      description: 'Password recovery screen',
      category: 'Authentication',
      role: 'all',
      icon: Icons.lock_reset,
      builder: (context) => const ForgotPasswordScreen(),
    ),
    PageRegistry(
      id: 'otp_verification',
      name: 'OTP Verification',
      description: 'OTP verification screen',
      category: 'Authentication',
      role: 'all',
      icon: Icons.pin,
      builder: (context) => const OTPVerificationScreen(),
    ),

    // ── Navigation ──
    PageRegistry(
      id: 'home',
      name: 'Home',
      description: 'Main home page',
      category: 'Navigation',
      role: 'all',
      icon: Icons.home,
      builder: (context) => const HomePage(),
    ),
    PageRegistry(
      id: 'mobile_home',
      name: 'Mobile Home',
      description: 'Mobile optimized home page',
      category: 'Navigation',
      role: 'all',
      icon: Icons.phone_android,
      builder: (context) => const MobileHome(),
    ),
    PageRegistry(
      id: 'dashboard',
      name: 'Dashboard',
      description: 'Main dashboard',
      category: 'Navigation',
      role: 'all',
      icon: Icons.dashboard,
      builder: (context) => const DashboardScreen(),
    ),


    // ── User Management ──
    PageRegistry(
      id: 'profile',
      name: 'Profile',
      description: 'User profile (profiles table)',
      category: 'User Management',
      role: 'all',
      icon: Icons.person,
      builder: (context) => const StudentProfileScreen(),
    ),
    PageRegistry(
      id: 'student_profile',
      name: 'Student Profile',
      description: 'Student profile details',
      category: 'User Management',
      role: 'student',
      icon: Icons.person_outline,
      builder: (context) => const StudentProfileScreen(),
    ),
    PageRegistry(
      id: 'parent_profile',
      name: 'Parent Profile',
      description: 'Parent profile details',
      category: 'User Management',
      role: 'parent',
      icon: Icons.person_outline,
      builder: (context) => const ParentProfileScreen(),
    ),
    PageRegistry(
      id: 'settings',
      name: 'Settings',
      description: 'Application settings',
      category: 'User Management',
      role: 'all',
      icon: Icons.settings,
      builder: (context) => const SettingsScreen(),
    ),
    PageRegistry(
      id: 'change_password',
      name: 'Change Password',
      description: 'Password change screen',
      category: 'User Management',
      role: 'all',
      icon: Icons.password,
      builder: (context) => const ChangePasswordScreen(),
    ),
    PageRegistry(
      id: 'notifications',
      name: 'Notifications',
      description: 'In-app notifications (notifications table)',
      category: 'User Management',
      role: 'all',
      icon: Icons.notifications,
      builder: (context) => const NotificationsScreen(),
    ),
    PageRegistry(
      id: 'student_notifications',
      name: 'My Notifications',
      description: 'Student notifications and announcements',
      category: 'User Management',
      role: 'student',
      icon: Icons.notifications_active,
      builder: (context) => const StudentNotificationsScreen(),
    ),
    PageRegistry(
      id: 'notification_preferences',
      name: 'Notification Preferences',
      description: 'Notification settings (notification_settings table)',
      category: 'User Management',
      role: 'all',
      icon: Icons.tune,
      builder: (context) => const NotificationPreferencesScreen(),
    ),
    PageRegistry(
      id: 'privacy_security',
      name: 'Privacy & Security',
      description: 'Privacy and security settings',
      category: 'User Management',
      role: 'all',
      icon: Icons.security,
      builder: (context) => const PrivacySecurityScreen(),
    ),


    // ── Communication ──
    PageRegistry(
      id: 'messages',
      name: 'Messages',
      description: 'Messages hub (parent_messages / chat_messages)',
      category: 'Communication',
      role: 'all',
      icon: Icons.message,
      builder: (context) => const MessagesHubScreen(),
    ),
    PageRegistry(
      id: 'parent_messaging',
      name: 'Parent Messaging',
      description: 'Contact teachers and school staff',
      category: 'Communication',
      role: 'parent',
      icon: Icons.forum,
      builder: (context) => const ParentMessagingScreen(),
    ),
    PageRegistry(
      id: 'chat',
      name: 'Chat',
      description: 'Chat conversations (chat_groups table)',
      category: 'Communication',
      role: 'all',
      icon: Icons.chat,
      builder: (context) => const ChatScreen(),
    ),
    PageRegistry(
      id: 'notice_board',
      name: 'Notice Board',
      description: 'School announcements (announcements table)',
      category: 'Communication',
      role: 'all',
      icon: Icons.campaign,
      builder: (context) => const NoticeBoardScreen(),
    ),
    PageRegistry(
      id: 'feedback',
      name: 'Feedback',
      description: 'Submit feedback (feedback table)',
      category: 'Communication',
      role: 'all',
      icon: Icons.rate_review,
      builder: (context) => const StudentFeedbackScreen(),
    ),
    PageRegistry(
      id: 'parent_feedback',
      name: 'Parent Feedback',
      description: 'Submit feedback to school',
      category: 'Communication',
      role: 'parent',
      icon: Icons.rate_review_outlined,
      builder: (context) => const ParentFeedbackScreen(),
    ),
    PageRegistry(
      id: 'help_support',
      name: 'Help & Support',
      description: 'FAQ and support tickets (support_tickets table)',
      category: 'Communication',
      role: 'all',
      icon: Icons.help,
      builder: (context) => const HelpSupportScreen(),
    ),
    PageRegistry(
      id: 'about_emis',
      name: 'About EMIS',
      description: 'About the education management system',
      category: 'Communication',
      role: 'all',
      icon: Icons.info,
      builder: (context) => const AboutEmisScreen(),
    ),

    // ── Student Portal (schema: courses, student_assignments, etc.) ──
    PageRegistry(
      id: 'student_courses',
      name: 'My Courses',
      description: 'Enrolled courses (courses / student_enrollments)',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.class_,
      builder: (context) => const CoursesScreen(),
    ),
    PageRegistry(
      id: 'student_assignments',
      name: 'Assignments',
      description: 'View and submit assignments (student_assignments / homework)',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.assignment,
      builder: (context) => const AssignmentsScreen(),
    ),
    PageRegistry(
      id: 'student_attendance',
      name: 'My Attendance',
      description: 'Attendance records (student_attendance table)',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.check_circle,
      builder: (context) => const AttendanceScreenRealtime(),
    ),
    PageRegistry(
      id: 'student_grades',
      name: 'My Grades',
      description: 'Grades and results (student_grades table)',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.grade,
      builder: (context) => const GradesScreenRealtime(),
    ),
    PageRegistry(
      id: 'student_resources',
      name: 'Course Resources',
      description: 'Course materials (course_resources table)',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.folder,
      builder: (context) => const ResourcesScreenRealtime(),
    ),
    PageRegistry(
      id: 'student_schedule',
      name: 'Class Schedule',
      description: 'Class timetable (student_schedules / timetables)',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.schedule,
      builder: (context) => const ScheduleScreenRealtime(),
    ),
    PageRegistry(
      id: 'grades',
      name: 'Grades',
      description: 'View grades and results',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.grade,
      builder: (context) => const GradesScreenRealtime(),
    ),
    PageRegistry(
      id: 'timetable',
      name: 'Timetable',
      description: 'Weekly class timetable',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.calendar_view_week,
      builder: (context) => const ScheduleScreenRealtime(),
    ),
    PageRegistry(
      id: 'my_schedule',
      name: 'My Schedule',
      description: 'Personal class schedule',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.calendar_today,
      builder: (context) => const TimetableViewScreen(),
    ),
    PageRegistry(
      id: 'lms',
      name: 'Learning Materials',
      description: 'Study materials (course_resources table)',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.school,
      builder: (context) => const StudyMaterialsScreen(),
    ),
    PageRegistry(
      id: 'exams',
      name: 'Exams',
      description: 'Upcoming and past exams (exams table)',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.quiz,
      builder: (context) => const ExamsScreen(),
    ),
    PageRegistry(
      id: 'results',
      name: 'Exam Results',
      description: 'Exam results (exam_results table)',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.assessment,
      builder: (context) => const ResultsScreen(),
    ),
    PageRegistry(
      id: 'certificates',
      name: 'Certificates',
      description: 'Earned certificates (certificates table)',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.card_membership,
      builder: (context) => const CertificatesScreen(),
    ),
    PageRegistry(
      id: 'academic_history',
      name: 'Academic History',
      description: 'Enrollment history (student_enrollments table)',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.history_edu,
      builder: (context) => const AcademicHistoryScreen(),
    ),
    PageRegistry(
      id: 'placement_test',
      name: 'Placement Test',
      description: 'English placement test',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.spellcheck,
      builder: (context) => const PlacementTestScreen(),
    ),
    PageRegistry(
      id: 'student_documents',
      name: 'My Documents',
      description: 'Uploaded documents (student_documents table)',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.folder_shared,
      builder: (context) => const StudentDocumentsScreen(),
    ),
    PageRegistry(
      id: 'student_leaves',
      name: 'Leave Applications',
      description: 'Apply for leave (student_leaves table)',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.event_busy,
      builder: (context) => const StudentLeaveScreen(),
    ),
    PageRegistry(
      id: 'fee_details',
      name: 'Fee Details',
      description: 'Fee breakdown (student_fee_assignments / payments)',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.payments,
      builder: (context) => const FeesPortalScreen(title: 'Fee Details'),
    ),
    PageRegistry(
      id: 'achievements',
      name: 'Achievements',
      description: 'Academic achievements and badges',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.emoji_events,
      builder: (context) => const AchievementsScreen(),
    ),
    PageRegistry(
      id: 'library',
      name: 'Library',
      description: 'Borrowed books (book_issues / library_books)',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.library_books,
      builder: (context) => const StudentLibraryScreen(),
    ),
    PageRegistry(
      id: 'digital_library',
      name: 'Digital Library',
      description: 'E-books and digital resources (digital_library table)',
      category: 'Student Portal',
      role: 'student',
      icon: Icons.menu_book,
      builder: (context) => const DigitalLibraryScreen(),
    ),

    // ── Parent Portal (schema: parent_students, invoices, etc.) ──
    PageRegistry(
      id: 'children_profile',
      name: 'My Children',
      description: 'Children profiles (parent_students table)',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.family_restroom,
      builder: (context) => const ChildrenProfileScreen(),
    ),
    PageRegistry(
      id: 'children_attendance',
      name: 'Children Attendance',
      description: 'Track children attendance',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.calendar_month,
      builder: (context) => const ChildrenAttendanceScreen(),
    ),
    PageRegistry(
      id: 'report_cards',
      name: 'Report Cards',
      description: 'Children report cards (grades / exam_results)',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.description,
      builder: (context) => const ReportCardsScreen(),
    ),
    PageRegistry(
      id: 'fee_payment_history',
      name: 'Fee Payment History',
      description: 'Payment history (payments table)',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.account_balance_wallet,
      builder: (context) => const FeesPortalScreen(
          title: 'Payment History', initialTabIndex: 2),
    ),
    PageRegistry(
      id: 'invoices',
      name: 'Invoices',
      description: 'Fee invoices (invoices table)',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.receipt_long,
      builder: (context) =>
          const FeesPortalScreen(title: 'Invoices', initialTabIndex: 1),
    ),
    PageRegistry(
      id: 'parent_teacher_meetings',
      name: 'Parent-Teacher Meetings',
      description: 'Schedule meetings with teachers',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.groups,
      builder: (context) => const ParentTeacherMeetingsScreen(),
    ),
    PageRegistry(
      id: 'calendar',
      name: 'School Calendar',
      description: 'Events and holidays (events / holidays tables)',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.event,
      builder: (context) => const SchoolCalendarScreen(),
    ),
    PageRegistry(
      id: 'school_calendar',
      name: 'School Calendar',
      description: 'School events calendar',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.calendar_today,
      builder: (context) => const SchoolCalendarScreen(),
    ),
    PageRegistry(
      id: 'events',
      name: 'Events',
      description: 'School events (events / event_registrations)',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.celebration,
      builder: (context) => const EventsRegistrationScreen(),
    ),
    PageRegistry(
      id: 'events_registration',
      name: 'Event Registration',
      description: 'Register for school events',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.event_available,
      builder: (context) => const EventsRegistrationScreen(),
    ),
    PageRegistry(
      id: 'transport_tracking',
      name: 'Transport Tracking',
      description: 'School transport tracking',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.directions_bus,
      builder: (context) => const TransportTrackingScreen(),
    ),
    PageRegistry(
      id: 'health_records',
      name: 'Health Records',
      description: 'Children health records',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.favorite,
      builder: (context) => const HealthRecordsScreen(),
    ),
    PageRegistry(
      id: 'parent_leave_applications',
      name: 'Leave Applications',
      description: 'Apply leave for children (student_leaves table)',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.event_available,
      builder: (context) => const ParentLeaveApplicationsScreen(),
    ),
    PageRegistry(
      id: 'parent_complaints',
      name: 'Complaints',
      description: 'Submit complaints (support_tickets table)',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.report_problem,
      builder: (context) => const ParentComplaintsScreen(),
    ),
    PageRegistry(
      id: 'co_curricular_activities',
      name: 'Co-Curricular Activities',
      description: 'Extracurricular activities',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.sports_soccer,
      builder: (context) => const CoCurricularActivitiesScreen(),
    ),
    PageRegistry(
      id: 'emergency_contacts',
      name: 'Emergency Contacts',
      description: 'Emergency contact information',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.emergency,
      builder: (context) => const EmergencyContactsScreen(),
    ),
    PageRegistry(
      id: 'parent_documents',
      name: 'Documents',
      description: 'Children documents (student_documents table)',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.folder,
      builder: (context) => const ParentDocumentsScreen(),
    ),
    PageRegistry(
      id: 'performance_tracking',
      name: 'Performance Tracking',
      description: 'Track children performance (student_progress table)',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.trending_up,
      builder: (context) => const PerformanceTrackingScreen(),
    ),
    PageRegistry(
      id: 'parent_settings',
      name: 'Parent Settings',
      description: 'Parent portal settings',
      category: 'Parent Portal',
      role: 'parent',
      icon: Icons.settings,
      builder: (context) => const ParentSettingsScreen(),
    ),

    // ── Academic (shared) ──
    PageRegistry(
      id: 'attendance',
      name: 'Attendance',
      description: 'Attendance tracking (attendance / student_attendance)',
      category: 'Academic',
      role: 'all',
      icon: Icons.check_circle,
      builder: (context) => const AttendanceScreen(),
    ),
    PageRegistry(
      id: 'books',
      name: 'Books',
      description: 'Book catalog (library_books table)',
      category: 'Academic',
      role: 'all',
      icon: Icons.book,
      builder: (context) => const BooksScreen(),
    ),
    PageRegistry(
      id: 'students',
      name: 'Students',
      description: 'Student directory (students table)',
      category: 'Academic',
      role: 'all',
      icon: Icons.school,
      builder: (context) => const StudentsScreen(),
    ),

    // ── Financial ──
    PageRegistry(
      id: 'payments',
      name: 'Payments',
      description: 'Payment history (payments table)',
      category: 'Financial',
      role: 'all',
      icon: Icons.payment,
      builder: (context) => const PaymentsScreen(),
    ),

    // ── Utility ──
    PageRegistry(
      id: 'our_story',
      name: 'Our Story',
      description: 'About us',
      category: 'Utility',
      role: 'all',
      icon: Icons.history,
      builder: (context) => const OurStoryScreen(),
    ),
    PageRegistry(
      id: 'english_test',
      name: 'English Test',
      description: 'English proficiency test',
      category: 'Utility',
      role: 'all',
      icon: Icons.translate,
      builder: (context) => const EnglishTestScreen(),
    ),
  ];

  static List<PageRegistry> getAllPages() {
    return _pages.where((page) => page.isActive).toList();
  }

  static List<PageRegistry> getPagesByRole(String role) {
    return _pages
        .where((page) =>
            page.isActive && (page.role == 'all' || page.role == role))
        .toList();
  }

  static List<PageRegistry> getPagesByCategory(String category) {
    return _pages
        .where((page) => page.isActive && page.category == category)
        .toList();
  }

  static PageRegistry? getPageById(String id) {
    try {
      return _pages.firstWhere((page) => page.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<String> getAllCategories() {
    final categories = _pages.map((page) => page.category).toSet().toList();
    categories.sort();
    return categories;
  }

  static List<PageRegistry> searchPages(String query) {
    final lowerQuery = query.toLowerCase();
    return _pages
        .where((page) =>
            page.isActive &&
            (page.name.toLowerCase().contains(lowerQuery) ||
                page.description.toLowerCase().contains(lowerQuery)))
        .toList();
  }
}
