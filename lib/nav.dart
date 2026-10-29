import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Screen Imports - ONLY for Student, Parent & Home
import 'package:course_users/screens/splash_screen.dart';
import 'package:course_users/screens/home_page.dart';
import 'package:course_users/screens/onboarding_screen.dart';
import 'package:course_users/screens/login_screen.dart';
import 'package:course_users/screens/signup_screen.dart';
import 'package:course_users/screens/forgot_password_screen.dart';
import 'package:course_users/screens/otp_verification_screen.dart';
import 'package:course_users/screens/change_password_screen.dart';
import 'package:course_users/screens/settings_screen.dart';
import 'package:course_users/screens/dashboard_screen.dart';
import 'package:course_users/screens/mobile_home.dart';
import 'package:course_users/screens/our_story_screen.dart';
import 'package:course_users/screens/english_test_screen.dart';

// Student Panel
import 'package:course_users/panels/student/student_panel_screen.dart';
import 'package:course_users/screens/student/student_screens.dart';

// Parent Panel
import 'package:course_users/panels/parent/parent_panel_screen.dart';
import 'package:course_users/screens/parent/parent_screens.dart';

// Schema-backed pages
import 'package:course_users/screens/schema_pages.dart';

// Fee portal (student + parent)
import 'package:course_users/screens/finance/fees_portal_screen.dart';
import 'package:course_users/screens/notifications_screen.dart';
import 'package:course_users/screens/chat_screen.dart';
import 'package:course_users/screens/chat_conversation_screen.dart';

// Common Screens
import 'package:course_users/screens/students_screen.dart';
import 'package:course_users/screens/payments_screen.dart';
import 'package:course_users/screens/books_screen.dart';
import 'package:course_users/screens/attendance_screen.dart';

// App Routes Constants
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String changePassword = '/change-password';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String dashboard = '/dashboard';
  static const String mobileHome = '/mobile-home';

  // Student Panel
  static const String studentPanel = '/student-panel';
  static const String studentCourses = '/student-courses';
  static const String studentAssignments = '/student-assignments';
  static const String studentAttendance = '/student-attendance';
  static const String studentGrades = '/student-grades';
  static const String studentResources = '/student-resources';
  static const String studentSchedule = '/student-schedule';

  // New Student Pages
  static const String exams = '/exams';
  static const String results = '/results';
  static const String certificates = '/certificates';
  static const String placementTest = '/placement-test';
  static const String academicHistory = '/academic-history';
  static const String studentProfile = '/student-profile';
  static const String library = '/library';
  static const String studentNotifications = '/student-notifications';
  static const String feedback = '/feedback';
  static const String studyMaterials = '/study-materials';
  static const String feeDetails = '/fee-details';
  static const String helpSupport = '/help-support';
  static const String privacySecurity = '/privacy-security';
  static const String achievements = '/achievements';

  // Parent Panel
  static const String parentPanel = '/parent-panel';
  static const String childrenProfile = '/children-profile';
  static const String feePaymentHistory = '/fee-payment-history';
  static const String parentTeacherMeetings = '/parent-teacher-meetings';
  static const String schoolCalendar = '/school-calendar';
  static const String transportTracking = '/transport-tracking';
  static const String healthRecords = '/health-records';
  static const String parentLeaveApplications = '/parent-leave-applications';
  static const String parentComplaints = '/parent-complaints';
  static const String noticeBoard = '/notice-board';
  static const String parentProfile = '/parent-profile';
  static const String emergencyContacts = '/emergency-contacts';
  static const String childrenAttendance = '/children-attendance';
  static const String reportCards = '/report-cards';
  static const String coCurricularActivities = '/co-curricular-activities';
  static const String parentSettings = '/parent-settings';
  static const String eventsRegistration = '/events-registration';

  // Student Part 2
  static const String courseDetail = '/course-detail';
  static const String assignmentSubmission = '/assignment-submission';
  static const String studentTimetable = '/student-timetable';
  static const String subjectProgress = '/subject-progress';
  static const String studyPlanner = '/study-planner';
  static const String onlineClasses = '/online-classes';
  static const String careerGuidance = '/career-guidance';
  static const String scholarships = '/scholarships';
  static const String sportsActivities = '/sports-activities';
  static const String mentalHealth = '/mental-health';

  // Student Part 3
  static const String gradesDetail = '/grades-detail';
  static const String discussionForum = '/discussion-forum';
  static const String projectManagement = '/project-management';
  static const String internshipTracker = '/internship-tracker';
  static const String exchangePrograms = '/exchange-programs';
  static const String studentClubs = '/student-clubs';
  static const String campusMap = '/campus-map';
  static const String studentMarketplace = '/student-marketplace';

  // Student Part 4
  static const String examPreparation = '/exam-preparation';
  static const String tutoring = '/tutoring';
  static const String wellness = '/wellness';
  static const String lostAndFound = '/lost-and-found';
  static const String canteen = '/canteen';
  static const String attendanceCalendar = '/attendance-calendar';
  static const String studentId = '/student-id';
  static const String notifPreferences = '/notification-preferences';

  // Schema-backed pages
  static const String notifications = '/notifications';
  static const String messages = '/messages';
  static const String chat = '/chat';
  static const String profile = '/profile';
  static const String digitalLibrary = '/digital-library';
  static const String studentDocuments = '/student-documents';
  static const String studentLeaves = '/student-leaves';
  static const String invoices = '/invoices';
  static const String aboutEmis = '/about-emis';
  static const String lms = '/lms';
  static const String mySchedule = '/my-schedule';

  // Parent Part 3
  static const String parentMessaging = '/parent-messaging';
  static const String performanceTracking = '/performance-tracking';
  static const String parentVolunteer = '/parent-volunteer';
  static const String parentDocuments = '/parent-documents';
  static const String schoolGallery = '/school-gallery';
  static const String parentAlumni = '/parent-alumni';
  static const String parentFeedback = '/parent-feedback';

  // Common
  static const String payments = '/payments';
  static const String attendance = '/attendance';
  static const String grades = '/grades';
  static const String courses = '/courses';
  static const String assignments = '/assignments';
  static const String timetable = '/timetable';
  static const String students = '/students';
  static const String books = '/books';
  static const String ourStory = '/our-story';
  static const String englishTest = '/english-test';
}

// Demo Mode Provider
final isDemoModeProvider = StateProvider<bool>((ref) => false);
final rootNavigatorKey = GlobalKey<NavigatorState>();

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isDemoMode = ref.read(isDemoModeProvider);
      final isAuth = session != null || isDemoMode;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup;
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final isHome = state.matchedLocation == AppRoutes.home;
      final isSplash = state.matchedLocation == AppRoutes.splash;

      // If it's splash screen, let it handle its own logic
      if (isSplash) return null;

      if (!isAuth &&
          !isAuthRoute &&
          !isOnboarding &&
          !isHome &&
          state.matchedLocation != '/forgot-password') {
        return AppRoutes.login;
      }

      // Handle authenticated user redirects
      if (session != null && isAuthRoute) {
        final user = Supabase.instance.client.auth.currentUser;
        final role = user?.userMetadata?['role']?.toString().toLowerCase();

        // Student Panel
        if (role == 'student') return AppRoutes.studentPanel;

        // Parent Panel
        if (role == 'parent') return AppRoutes.parentPanel;

        // Default to home
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        name: 'otp-verification',
        builder: (context, state) => const OTPVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        name: 'change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      // Main Routes
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.mobileHome,
        name: 'mobile-home',
        builder: (context, state) => const MobileHome(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),



      // Student Panel Routes
      GoRoute(
        path: AppRoutes.studentPanel,
        name: 'student-panel',
        builder: (context, state) => const StudentPanelScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentCourses,
        name: 'student-courses',
        builder: (context, state) => const CoursesScreen(),
      ),
      GoRoute(
        path: AppRoutes.courses,
        name: 'courses',
        builder: (context, state) => const CoursesScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentAssignments,
        name: 'student-assignments',
        builder: (context, state) => const AssignmentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.assignments,
        name: 'assignments',
        builder: (context, state) => const AssignmentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentAttendance,
        name: 'student-attendance',
        builder: (context, state) => const AttendanceScreenRealtime(),
      ),
      GoRoute(
        path: AppRoutes.studentGrades,
        name: 'student-grades',
        builder: (context, state) => const GradesScreenRealtime(),
      ),
      GoRoute(
        path: AppRoutes.grades,
        name: 'grades',
        builder: (context, state) => const GradesScreenRealtime(),
      ),
      GoRoute(
        path: AppRoutes.studentResources,
        name: 'student-resources',
        builder: (context, state) => const ResourcesScreenRealtime(),
      ),
      GoRoute(
        path: AppRoutes.studentSchedule,
        name: 'student-schedule',
        builder: (context, state) => const ScheduleScreenRealtime(),
      ),
      GoRoute(
        path: AppRoutes.timetable,
        name: 'timetable',
        builder: (context, state) => const ScheduleScreenRealtime(),
      ),

      // New Student Routes
      GoRoute(
        path: AppRoutes.exams,
        name: 'exams',
        builder: (context, state) => const ExamsScreen(),
      ),
      GoRoute(
        path: AppRoutes.results,
        name: 'results',
        builder: (context, state) => const ResultsScreen(),
      ),
      GoRoute(
        path: AppRoutes.certificates,
        name: 'certificates',
        builder: (context, state) => const CertificatesScreen(),
      ),
      GoRoute(
        path: AppRoutes.placementTest,
        name: 'placement-test',
        builder: (context, state) => const PlacementTestScreen(),
      ),
      GoRoute(
        path: AppRoutes.academicHistory,
        name: 'academic-history',
        builder: (context, state) => const AcademicHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentProfile,
        name: 'student-profile',
        builder: (context, state) => const StudentProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.library,
        name: 'library',
        builder: (context, state) => const StudentLibraryScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentNotifications,
        name: 'student-notifications',
        builder: (context, state) => const StudentNotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.feedback,
        name: 'feedback',
        builder: (context, state) => const StudentFeedbackScreen(),
      ),
      GoRoute(
        path: AppRoutes.studyMaterials,
        name: 'study-materials',
        builder: (context, state) => const StudyMaterialsScreen(),
      ),
      GoRoute(
        path: AppRoutes.feeDetails,
        name: 'fee-details',
        builder: (context, state) =>
            const FeesPortalScreen(title: 'Fee Details'),
      ),
      GoRoute(
        path: AppRoutes.helpSupport,
        name: 'help-support',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacySecurity,
        name: 'privacy-security',
        builder: (context, state) => const PrivacySecurityScreen(),
      ),
      GoRoute(
        path: AppRoutes.achievements,
        name: 'achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),

      // Parent Panel Routes
      GoRoute(
        path: AppRoutes.parentPanel,
        name: 'parent-panel',
        builder: (context, state) => const ParentPanelScreen(),
      ),
      GoRoute(
        path: AppRoutes.childrenProfile,
        name: 'children-profile',
        builder: (context, state) => const ChildrenProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.feePaymentHistory,
        name: 'fee-payment-history',
        builder: (context, state) => const FeesPortalScreen(
            title: 'Payment History', initialTabIndex: 2),
      ),
      GoRoute(
        path: AppRoutes.parentTeacherMeetings,
        name: 'parent-teacher-meetings',
        builder: (context, state) => const ParentTeacherMeetingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.schoolCalendar,
        name: 'school-calendar',
        builder: (context, state) => const SchoolCalendarScreen(),
      ),
      GoRoute(
        path: AppRoutes.transportTracking,
        name: 'transport-tracking',
        builder: (context, state) => const TransportTrackingScreen(),
      ),
      GoRoute(
        path: AppRoutes.healthRecords,
        name: 'health-records',
        builder: (context, state) => const HealthRecordsScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentLeaveApplications,
        name: 'parent-leave-applications',
        builder: (context, state) => const ParentLeaveApplicationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentComplaints,
        name: 'parent-complaints',
        builder: (context, state) => const ParentComplaintsScreen(),
      ),
      GoRoute(
        path: AppRoutes.noticeBoard,
        name: 'notice-board',
        builder: (context, state) => const NoticeBoardScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentProfile,
        name: 'parent-profile',
        builder: (context, state) => const ParentProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.emergencyContacts,
        name: 'emergency-contacts',
        builder: (context, state) => const EmergencyContactsScreen(),
      ),
      GoRoute(
        path: AppRoutes.childrenAttendance,
        name: 'children-attendance',
        builder: (context, state) => const ChildrenAttendanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.reportCards,
        name: 'report-cards',
        builder: (context, state) => const ReportCardsScreen(),
      ),
      GoRoute(
        path: AppRoutes.coCurricularActivities,
        name: 'co-curricular-activities',
        builder: (context, state) => const CoCurricularActivitiesScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentSettings,
        name: 'parent-settings',
        builder: (context, state) => const ParentSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.eventsRegistration,
        name: 'events-registration',
        builder: (context, state) => const EventsRegistrationScreen(),
      ),

      // Student Part 2 Routes
      GoRoute(
        path: '${AppRoutes.courseDetail}/:id',
        name: 'course-detail',
        builder: (context, state) =>
            CourseDetailScreen(courseId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '${AppRoutes.assignmentSubmission}/:id',
        name: 'assignment-submission',
        builder: (context, state) => AssignmentSubmissionScreen(
            assignmentId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.studentTimetable,
        name: 'student-timetable',
        builder: (context, state) => const TimetableViewScreen(),
      ),
      GoRoute(
        path: AppRoutes.subjectProgress,
        name: 'subject-progress',
        builder: (context, state) => const SubjectProgressScreen(),
      ),
      GoRoute(
        path: AppRoutes.studyPlanner,
        name: 'study-planner',
        builder: (context, state) => const StudyPlannerScreen(),
      ),
      GoRoute(
        path: AppRoutes.onlineClasses,
        name: 'online-classes',
        builder: (context, state) => const OnlineClassesScreen(),
      ),
      GoRoute(
        path: AppRoutes.careerGuidance,
        name: 'career-guidance',
        builder: (context, state) => const CareerGuidanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.scholarships,
        name: 'scholarships',
        builder: (context, state) => const ScholarshipScreen(),
      ),
      GoRoute(
        path: AppRoutes.sportsActivities,
        name: 'sports-activities',
        builder: (context, state) => const SportsActivitiesScreen(),
      ),
      GoRoute(
        path: AppRoutes.mentalHealth,
        name: 'mental-health',
        builder: (context, state) => const MentalHealthScreen(),
      ),

      // Student Part 3 Routes
      GoRoute(
        path: AppRoutes.gradesDetail,
        name: 'grades-detail',
        builder: (context, state) => const GradesDetailScreen(),
      ),
      GoRoute(
        path: AppRoutes.discussionForum,
        name: 'discussion-forum',
        builder: (context, state) => const DiscussionForumScreen(),
      ),
      GoRoute(
        path: AppRoutes.projectManagement,
        name: 'project-management',
        builder: (context, state) => const ProjectManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.internshipTracker,
        name: 'internship-tracker',
        builder: (context, state) => const InternshipTrackerScreen(),
      ),
      GoRoute(
        path: AppRoutes.exchangePrograms,
        name: 'exchange-programs',
        builder: (context, state) => const ExchangeProgramsScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentClubs,
        name: 'student-clubs',
        builder: (context, state) => const StudentClubsScreen(),
      ),
      GoRoute(
        path: AppRoutes.campusMap,
        name: 'campus-map',
        builder: (context, state) => const CampusMapScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentMarketplace,
        name: 'student-marketplace',
        builder: (context, state) => const StudentMarketplaceScreen(),
      ),

      // Student Part 4 Routes
      GoRoute(
        path: AppRoutes.examPreparation,
        name: 'exam-preparation',
        builder: (context, state) => const ExamPreparationScreen(),
      ),
      GoRoute(
        path: AppRoutes.tutoring,
        name: 'tutoring',
        builder: (context, state) => const TutoringScreen(),
      ),
      GoRoute(
        path: AppRoutes.wellness,
        name: 'wellness',
        builder: (context, state) => const WellnessScreen(),
      ),
      GoRoute(
        path: AppRoutes.lostAndFound,
        name: 'lost-and-found',
        builder: (context, state) => const LostAndFoundScreen(),
      ),
      GoRoute(
        path: AppRoutes.canteen,
        name: 'canteen',
        builder: (context, state) => const CanteenScreen(),
      ),
      GoRoute(
        path: AppRoutes.attendanceCalendar,
        name: 'attendance-calendar',
        builder: (context, state) => const AttendanceCalendarScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentId,
        name: 'student-id',
        builder: (context, state) => const StudentIdScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifPreferences,
        name: 'notification-preferences',
        builder: (context, state) => const NotificationPreferencesScreen(),
      ),

      // Schema-backed & communication routes
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.messages,
        name: 'messages',
        builder: (context, state) => const MessagesHubScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'chat-conversation',
            builder: (context, state) => ChatConversationScreen(
              chatId: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const StudentProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.digitalLibrary,
        name: 'digital-library',
        builder: (context, state) => const DigitalLibraryScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentDocuments,
        name: 'student-documents',
        builder: (context, state) => const StudentDocumentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentLeaves,
        name: 'student-leaves',
        builder: (context, state) => const StudentLeaveScreen(),
      ),
      GoRoute(
        path: AppRoutes.invoices,
        name: 'invoices',
        builder: (context, state) =>
            const FeesPortalScreen(title: 'Invoices', initialTabIndex: 1),
      ),
      GoRoute(
        path: AppRoutes.aboutEmis,
        name: 'about-emis',
        builder: (context, state) => const AboutEmisScreen(),
      ),
      GoRoute(
        path: AppRoutes.lms,
        name: 'lms',
        builder: (context, state) => const StudyMaterialsScreen(),
      ),
      GoRoute(
        path: AppRoutes.mySchedule,
        name: 'my-schedule',
        builder: (context, state) => const TimetableViewScreen(),
      ),

      // Parent Part 3 Routes
      GoRoute(
        path: AppRoutes.parentMessaging,
        name: 'parent-messaging',
        builder: (context, state) => const ParentMessagingScreen(),
      ),
      GoRoute(
        path: AppRoutes.performanceTracking,
        name: 'performance-tracking',
        builder: (context, state) => const PerformanceTrackingScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentVolunteer,
        name: 'parent-volunteer',
        builder: (context, state) => const ParentVolunteerScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentDocuments,
        name: 'parent-documents',
        builder: (context, state) => const ParentDocumentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.schoolGallery,
        name: 'school-gallery',
        builder: (context, state) => const SchoolGalleryScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentAlumni,
        name: 'parent-alumni',
        builder: (context, state) => const ParentAlumniScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentFeedback,
        name: 'parent-feedback',
        builder: (context, state) => const ParentFeedbackScreen(),
      ),

      // Common Screens
      GoRoute(
        path: AppRoutes.students,
        name: 'students',
        builder: (context, state) => const StudentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.payments,
        name: 'payments',
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.books,
        name: 'books',
        builder: (context, state) => const BooksScreen(),
      ),
      GoRoute(
        path: AppRoutes.attendance,
        name: 'attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),

      // Utility Routes
      GoRoute(
        path: AppRoutes.ourStory,
        name: 'our-story',
        builder: (context, state) => const OurStoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.englishTest,
        name: 'english-test',
        builder: (context, state) => const EnglishTestScreen(),
      ),
    ],
  );
});
