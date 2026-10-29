/// Centralized typed locale keys for type-safe lookups.
abstract final class L {
  // ─── App ───
  static const appName = 'app_name';
  static const welcome = 'welcome';

  // ─── Common Actions ───
  static const continue_ = 'continue';
  static const submit = 'submit';
  static const cancel = 'cancel';
  static const save = 'save';
  static const delete = 'delete';
  static const edit = 'edit';
  static const add = 'add';
  static const search = 'search';
  static const searchHint = 'search_hint';
  static const filter = 'filter';
  static const loading = 'loading';
  static const error_ = 'error';
  static const retry = 'retry';
  static const noData = 'no_data';
  static const today = 'today';
  static const back = 'back';
  static const next = 'next';
  static const done = 'done';
  static const close = 'close';
  static const confirm = 'confirm';
  static const yes = 'yes';
  static const no = 'no';
  static const ok = 'ok';
  static const apply = 'apply';
  static const clear = 'clear';
  static const select = 'select';
  static const or = 'or';

  // ─── Auth ───
  static const login = 'login';
  static const signup = 'signup';
  static const email = 'email';
  static const password = 'password';
  static const fullName = 'full_name';
  static const invalidEmail = 'invalid_email';
  static const min6Chars = 'min_6_characters';
  static const required = 'required';
  static const createAccount = 'create_account';
  static const alreadyHaveAccount = 'already_have_account';
  static const forgotPassword = 'forgot_password';
  static const resetPassword = 'reset_password';
  static const signIn = 'sign_in';
  static const signUp = 'sign_up';
  static const dontHaveAccount = 'dont_have_account';
  static const phoneNumber = 'phone_number';
  static const role = 'role';
  static const selectRole = 'select_role';
  static const confirmPassword = 'confirm_password';
  static const otpVerification = 'otp_verification';
  static const changePassword = 'change_password';
  static const currentPassword = 'current_password';
  static const newPassword = 'new_password';
  static const updateProfile = 'update_profile';
  static const profileUpdated = 'profile_updated';
  static const passwordChanged = 'password_changed';
  static const logout = 'logout';

  // ─── Navigation ───
  static const dashboard = 'dashboard';
  static const home = 'home';
  static const profile = 'profile';
  static const settings = 'settings';
  static const notifications = 'notifications';
  static const analytics = 'analytics';
  static const students = 'students';
  static const reports = 'reports';
  static const messages = 'messages';
  static const moreOptions = 'more_options';
  static const quickAccess = 'quick_access';
  static const chat = 'chat';
  static const menu = 'menu';

  // ─── Theme & Locale ───
  static const selectLanguage = 'select_language';
  static const themeMode = 'theme_mode';
  static const light = 'light';
  static const dark = 'dark';
  static const auto = 'auto';
  static const language = 'language';
  static const theme = 'theme';
  static const darkMode = 'dark_mode';
  static const lightMode = 'light_mode';
  static const systemMode = 'system_mode';
  static const changeLanguage = 'change_language';
  static const switchTheme = 'switch_theme';

  // ─── Panels ───
  static const superAdminPanel = 'super_admin_panel';
  static const adminPanel = 'admin_panel';
  static const teacherPanel = 'teacher_panel';
  static const studentPanel = 'student_panel';
  static const parentPanel = 'parent_panel';
  static const instructorPanel = 'instructor_panel';

  // ─── About / Misc ───
  static const about = 'about';
  static const aboutApp = 'about_app';
  static const version = 'version';
  static const developer = 'developer';
  static const contactSupport = 'contact_support';
  static const helpSupport = 'help_support';
  static const privacyPolicy = 'privacy_policy';
  static const termsOfService = 'terms_of_service';
  static const appUpdate = 'app_update';
}

// ═══════════════════════════════════════════
//  NAV SECTION
// ═══════════════════════════════════════════
abstract final class LNav {
  static const students = 'nav_students';
  static const teachers = 'nav_teachers';
  static const payments = 'nav_payments';
  static const attendance = 'nav_attendance';
  static const grades = 'nav_grades';
  static const exams = 'nav_exams';
  static const timetable = 'nav_timetable';
  static const courses = 'nav_courses';
  static const books = 'nav_books';
  static const feedback = 'nav_feedback';
  static const lms = 'nav_lms';
  static const announcements = 'nav_announcements';
  static const library = 'nav_library';
  static const inbox = 'nav_inbox';
}

// ═══════════════════════════════════════════
//  DASHBOARD / PANELS
// ═══════════════════════════════════════════
abstract final class LDash {
  static const welcomeBack = 'dash_welcome_back';
  static const quickActions = 'dash_quick_actions';
  static const recentActivity = 'dash_recent_activity';
  static const upcomingEvents = 'dash_upcoming_events';
  static const viewAll = 'dash_view_all';
  static const totalStudents = 'dash_total_students';
  static const totalTeachers = 'dash_total_teachers';
  static const activeCourses = 'dash_active_courses';
  static const pendingPayments = 'dash_pending_payments';
  static const todaysClasses = 'dash_todays_classes';
  static const totalUsers = 'dash_total_users';
  static const totalRevenue = 'dash_total_revenue';
  static const totalEnrollments = 'dash_total_enrollments';
  static const totalContent = 'dash_total_content';
  static const quickStats = 'dash_quick_stats';
  static const platformAnalytics = 'dash_platform_analytics';
  static const courseAnalytics = 'dash_course_analytics';
  static const revenueTrend = 'dash_revenue_trend';
  static const enrollmentTrend = 'dash_enrollment_trend';
  static const userDistribution = 'dash_user_distribution';
  static const contentMix = 'dash_content_mix';
}

// ═══════════════════════════════════════════
//  SUPER ADMIN
// ═══════════════════════════════════════════
abstract final class LSuperAdmin {
  static const title = 'sa_title';
  static const subtitle = 'sa_subtitle';
  static const platformOverview = 'sa_platform_overview';
  static const userManagement = 'sa_user_management';
  static const courseOverview = 'sa_course_overview';
  static const manageUsers = 'sa_manage_users';
  static const platformSettings = 'sa_platform_settings';
  static const systemLogs = 'sa_system_logs';
  static const modules = 'sa_modules';
}

// ═══════════════════════════════════════════
//  ADMIN
// ═══════════════════════════════════════════
abstract final class LAdmin {
  static const title = 'admin_title';
  static const subtitle = 'admin_subtitle';
  static const courseAdministration = 'admin_course_administration';
  static const courseManagement = 'admin_course_management';
  static const enrollmentManagement = 'admin_enrollment_management';
  static const instructorManagement = 'admin_instructor_management';
  static const modules = 'admin_modules';
  static const subCourses = 'admin_sub_courses';
  static const content = 'admin_content';
  static const instructors = 'admin_instructors';
  static const reviews = 'admin_reviews';
  static const trackEnrollments = 'admin_track_enrollments';
}

// ═══════════════════════════════════════════
//  INSTRUCTOR / TEACHER
// ═══════════════════════════════════════════
abstract final class LInstructor {
  static const title = 'instructor_title';
  static const subtitle = 'instructor_subtitle';
  static const teachingHub = 'instructor_teaching_hub';
  static const myCourses = 'instructor_my_courses';
  static const myStudents = 'instructor_my_students';
  static const courseContent = 'instructor_course_content';
  static const modules = 'instructor_modules';
  static const schedule = 'instructor_schedule';
  static const assignments = 'instructor_assignments';
  static const studentEngagement = 'instructor_student_engagement';
}

// ═══════════════════════════════════════════
//  COURSES
// ═══════════════════════════════════════════
abstract final class LCourse {
  static const myCourses = 'course_my_courses';
  static const availableCourses = 'course_available_courses';
  static const courseDetails = 'course_details';
  static const enroll = 'course_enroll';
  static const enrolled = 'course_enrolled';
  static const instructor = 'course_instructor';
  static const duration = 'course_duration';
  static const level = 'course_level';
  static const price = 'course_price';
  static const description = 'course_description';
  static const schedule = 'course_schedule';
  static const syllabus = 'course_syllabus';
  static const materials = 'course_materials';
  static const assignments = 'course_assignments';
  static const createCourse = 'course_create';
  static const editCourse = 'course_edit';
  static const deleteCourse = 'course_delete';
  static const courseName = 'course_name';
  static const courseCode = 'course_code';
  static const category = 'course_category';
  static const status = 'course_status';
  static const active = 'course_active';
  static const inactive = 'course_inactive';
  static const startDate = 'course_start_date';
  static const endDate = 'course_end_date';
  static const maxStudents = 'course_max_students';
  static const subCourses = 'course_sub_courses';
  static const contentItems = 'course_content_items';
  static const noCourses = 'course_no_courses';
  static const allCourses = 'course_all_courses';
}

// ═══════════════════════════════════════════
//  ENROLLMENTS
// ═══════════════════════════════════════════
abstract final class LEnrollment {
  static const title = 'enrollment_title';
  static const enrollmentDate = 'enrollment_date';
  static const enrolledStudents = 'enrolled_students';
  static const enrollStudent = 'enroll_student';
  static const unenroll = 'unenroll';
  static const status = 'enrollment_status';
  static const active = 'enrollment_active';
  static const completed = 'enrollment_completed';
  static const dropped = 'enrollment_dropped';
  static const noEnrollments = 'no_enrollments';
}

// ═══════════════════════════════════════════
//  CONTENT
// ═══════════════════════════════════════════
abstract final class LContent {
  static const title = 'content_title';
  static const addContent = 'content_add';
  static const editContent = 'content_edit';
  static const deleteContent = 'content_delete';
  static const contentType = 'content_type';
  static const video = 'content_video';
  static const document = 'content_document';
  static const quiz = 'content_quiz';
  static const assignment = 'content_assignment';
  static const resource = 'content_resource';
  static const title_ = 'content_title_field';
  static const fileUrl = 'content_file_url';
  static const orderIndex = 'content_order_index';
  static const isPublished = 'content_is_published';
}

// ═══════════════════════════════════════════
//  PAYMENTS
// ═══════════════════════════════════════════
abstract final class LPayment {
  static const title = 'payment_title';
  static const makePayment = 'payment_make';
  static const paymentHistory = 'payment_history';
  static const paymentDetails = 'payment_details';
  static const amount = 'payment_amount';
  static const paymentMethod = 'payment_method';
  static const transactionId = 'payment_transaction_id';
  static const paymentDate = 'payment_date';
  static const status = 'payment_status';
  static const paid = 'payment_paid';
  static const unpaid = 'payment_unpaid';
  static const pending = 'payment_pending';
  static const refunded = 'payment_refunded';
  static const receipt = 'payment_receipt';
  static const downloadReceipt = 'payment_download_receipt';
  static const addPayment = 'payment_add';
  static const totalRevenue = 'payment_total_revenue';
  static const noPayments = 'payment_no_payments';
}

// ═══════════════════════════════════════════
//  REVIEWS
// ═══════════════════════════════════════════
abstract final class LReview {
  static const title = 'review_title';
  static const rating = 'review_rating';
  static const comment = 'review_comment';
  static const submitReview = 'review_submit';
  static const noReviews = 'review_no_reviews';
  static const averageRating = 'review_average_rating';
}

// ═══════════════════════════════════════════
//  FORMS & VALIDATION
// ═══════════════════════════════════════════
abstract final class LForm {
  static const create = 'form_create';
  static const update = 'form_update';
  static const delete = 'form_delete';
  static const name = 'form_name';
  static const title = 'form_title';
  static const description = 'form_description';
  static const status = 'form_status';
  static const active = 'form_active';
  static const inactive = 'form_inactive';
  static const saveChanges = 'form_save_changes';
  static const discardChanges = 'form_discard_changes';
  static const confirmDelete = 'form_confirm_delete';
  static const deleteWarning = 'form_delete_warning';
  static const success = 'form_success';
  static const failed = 'form_failed';
  static const requiredField = 'form_required_field';
  static const invalidInput = 'form_invalid_input';
}

// ═══════════════════════════════════════════
//  NOTIFICATIONS
// ═══════════════════════════════════════════
abstract final class LNotif {
  static const title = 'notif_title';
  static const pushNotifications = 'notif_push';
  static const paymentReminders = 'notif_payment_reminders';
  static const examReminders = 'notif_exam_reminders';
  static const attendanceAlerts = 'notif_attendance_alerts';
  static const markAsRead = 'notif_mark_read';
  static const noNotifications = 'notif_no_notifications';
}

// ═══════════════════════════════════════════
//  HOME PAGE
// ═══════════════════════════════════════════
abstract final class LHome {
  static const tagline = 'home_tagline';
  static const heading = 'home_heading';
  static const subtitle1 = 'home_subtitle_1';
  static const subtitle2 = 'home_subtitle_2';
  static const subtitle3 = 'home_subtitle_3';
  static const startNow = 'home_start_now';
  static const previewMobile = 'home_preview_mobile';
  static const liveDashboards = 'home_live_dashboards';
  static const modules = 'home_modules';
  static const responsive = 'home_responsive';
  static const designedForInstitute = 'home_designed_for_institute';
  static const designSubtitle = 'home_design_subtitle';
  static const builtInCampaigns = 'home_built_in_campaigns';
  static const campaignsSubtitle = 'home_campaigns_subtitle';
  static const openAds = 'home_open_ads';
  static const dashboardPreview = 'home_dashboard_preview';
  static const students = 'home_students';
  static const studentsValue = 'home_students_value';
  static const studentsTrend = 'home_students_trend';
  static const revenueValue = 'home_revenue_value';
  static const revenueTrend = 'home_revenue_trend';
  static const weeklyMomentum = 'home_weekly_momentum';
  static const momentumSubtitle = 'home_momentum_subtitle';
  static const activeInstitutes = 'home_active_institutes';
  static const totalStudents = 'home_total_students';
  static const expertTeachers = 'home_expert_teachers';
  static const activeClasses = 'home_active_classes';
  static const dailyActiveStudents = 'home_daily_active_students';
  static const platformUptime = 'home_platform_uptime';
  static const support247 = 'home_support_247';
  static const trustedByEducators = 'home_trusted_by_educators';
  static const watchDemo = 'home_watch_demo';
  static const testimonialFallback = 'home_testimonial_fallback';
  static const testimonialFallbackSub = 'home_testimonial_fallback_sub';
  static const footerDesc = 'home_footer_desc';
  static const product = 'home_product';
  static const features = 'home_features';
  static const mobileUi = 'home_mobile_ui';
  static const reports = 'home_reports';
  static const ads = 'home_ads';
  static const company = 'home_company';
  static const about = 'home_about';
  static const support = 'home_support';
  static const contact = 'home_contact';
  static const security = 'home_security';
  static const legal = 'home_legal';
  static const privacy = 'home_privacy';
  static const terms = 'home_terms';
  static const policy = 'home_policy';
  static const copyright = 'home_copyright';
  static const dashboardOverview = 'home_dashboard_overview';
  static const dashboardSubtitle = 'home_dashboard_subtitle';
  static const totalStudentsCard = 'home_total_students_card';
  static const studentsCardValue = 'home_students_card_value';
  static const studentsCardSub = 'home_students_card_sub';
  static const activeCoursesCard = 'home_active_courses_card';
  static const coursesCardValue = 'home_courses_card_value';
  static const coursesCardSub = 'home_courses_card_sub';
  static const completionRate = 'home_completion_rate';
  static const completionValue = 'home_completion_value';
  static const completionSub = 'home_completion_sub';
  static const revenueCard = 'home_revenue_card';
  static const revenueCardValue = 'home_revenue_card_value';
  static const revenueCardSub = 'home_revenue_card_sub';
  static const analyticsPerformance = 'home_analytics_performance';
  static const enrollmentTrend = 'home_enrollment_trend';
  static const subjectPerformance = 'home_subject_performance';
  static const courseStatusDist = 'home_course_status_dist';
  static const quickActions = 'home_quick_actions';
  static const browseCourses = 'home_browse_courses';
  static const myLearning = 'home_my_learning';
  static const certificates = 'home_certificates';
  static const messages = 'home_messages';
  static const settings = 'home_settings';
  static const helpSupport = 'home_help_support';

  // Home page sections — Top Students, Our Teachers, etc.
  static const topStudents = 'home_top_students';
  static const topStudentsSub = 'home_top_students_sub';
  static const topPerformer = 'home_top_performer';
  static const gradeLabel = 'home_grade_label';
  static const ourTeachers = 'home_our_teachers';
  static const ourTeachersSub = 'home_our_teachers_sub';
  static const experiencedEducator = 'home_experienced_educator';
  static const yearsExp = 'home_years_exp';

  // Nav labels
  static const courses = 'home_courses';
  static const chat = 'home_chat';
  static const menu = 'home_menu';

  // Quick links
  static const quickMyAccount = 'home_quick_my_account';
  static const quickWhoWeAre = 'home_quick_who_we_are';
  static const quickOurNewClasses = 'home_quick_our_new_classes';
  static const quickBranches = 'home_quick_branches';
  static const quickWhyDreamflow = 'home_quick_why_dreamflow';

  // Menu items
  static const menuOurStory = 'home_menu_our_story';
  static const menuOurCourses = 'home_menu_our_courses';
  static const menuOurBranches = 'home_menu_our_branches';
  static const menuNewClasses = 'home_menu_new_classes';
  static const menuTestEnglish = 'home_menu_test_english';
  static const menuApplyOnline = 'home_menu_apply_online';
  static const menuRequestCall = 'home_menu_request_call';
  static const menuWhyOurCourse = 'home_menu_why_our_course';
  static const menuOurReviews = 'home_menu_our_reviews';
  static const menuContactCourse = 'home_menu_contact_course';

  // Screen titles
  static const ourCoursesTitle = 'home_our_courses_title';
  static const ourBranchesTitle = 'home_our_branches_title';
  static const newClassesTitle = 'home_new_classes_title';

  // Formatted labels
  static const levelFmt = 'home_level_fmt';
  static const durationFmt = 'home_duration_fmt';
  static const seatsFmt = 'home_seats_fmt';
  static const studentsFmt = 'home_students_fmt';
  static const scheduleTbd = 'home_schedule_tbd';
  static const statusOpen = 'home_status_open';
  static const statusClosed = 'home_status_closed';

  // Empty state
  static const noCourses = 'home_no_courses';
  static const noBranches = 'home_no_branches';
  static const noClasses = 'home_no_classes';

  // Apply Online screen
  static const applyOnlineTitle = 'home_apply_online_title';
  static const startYourJourney = 'home_start_your_journey';
  static const fillDetails = 'home_fill_details';
  static const courseInterested = 'home_course_interested';
  static const messageOptional = 'home_message_optional';
  static const submitApplication = 'home_submit_application';
  static const pleaseFillRequired = 'home_please_fill_required';
  static const applicationSubmitted = 'home_application_submitted';

  // Request a Call screen
  static const requestCallTitle = 'home_request_call_title';
  static const weCallYouBack = 'home_we_call_you_back';
  static const leaveNumber = 'home_leave_number';
  static const bestTimeToCall = 'home_best_time_to_call';
  static const timeHint = 'home_time_hint';
  static const requestCallBtn = 'home_request_call_btn';
  static const pleaseEnterPhone = 'home_please_enter_phone';
  static const wellCallShortly = 'home_well_call_shortly';

  // Why Our Course screen
  static const whyOurCourseTitle = 'home_why_our_course_title';
  static const noInfo = 'home_no_info';

  // Our Reviews screen
  static const ourReviewsTitle = 'home_our_reviews_title';
  static const noReviewsYet = 'home_no_reviews_yet';

  // Contact Course screen
  static const contactCourseTitle = 'home_contact_course_title';
  static const getInTouch = 'home_get_in_touch';
  static const weLoveToHear = 'home_we_love_to_hear';
  static const address = 'home_address';
  static const phone = 'home_phone';
  static const email = 'home_email';
  static const officeHours = 'home_office_hours';
  static const yourMessage = 'home_your_message';
  static const sendMessage = 'home_send_message';
  static const pleaseEnterMessage = 'home_please_enter_message';
  static const messageSent = 'home_message_sent';

  // Error / status
  static const failedToLoad = 'home_failed_to_load';

  // Additional sections — Story, Branches, Vision
  static const storyDesc = 'home_story_desc';
  static const branchesSub = 'home_branches_sub';
  static const visionTitle = 'home_vision_title';
  static const visionInnovation = 'home_vision_innovation';
  static const visionInnovationDesc = 'home_vision_innovation_desc';
  static const visionAccessibility = 'home_vision_accessibility';
  static const visionAccessibilityDesc = 'home_vision_accessibility_desc';
  static const visionExcellence = 'home_vision_excellence';
  static const visionExcellenceDesc = 'home_vision_excellence_desc';

  // Dashboard suffix (appended after app name)
  static const dashboardSuffix = 'home_dashboard_suffix';

  // Fallback names
  static const fallbackStudent = 'home_fallback_student';
  static const fallbackTeacher = 'home_fallback_teacher';

  // Dashboard stat card values/subtitles (demo data)
  static const statStudentsVal = 'home_stat_students_val';
  static const statStudentsSub = 'home_stat_students_sub';
  static const statCoursesVal = 'home_stat_courses_val';
  static const statCoursesSub = 'home_stat_courses_sub';
  static const statCompletionVal = 'home_stat_completion_val';
  static const statCompletionSub = 'home_stat_completion_sub';
  static const statRevenueVal = 'home_stat_revenue_val';
  static const statRevenueSub = 'home_stat_revenue_sub';

  // Chart status labels
  static const statusInProgress = 'home_status_in_progress';

  // Chart subject labels
  static const subjectMath = 'home_subject_math';
  static const subjectScience = 'home_subject_science';
  static const subjectEnglish = 'home_subject_english';
  static const subjectHistory = 'home_subject_history';
  static const subjectArt = 'home_subject_art';

  // Month abbreviations (chart labels)
  static const monthJan = 'home_month_jan';
  static const monthFeb = 'home_month_feb';
  static const monthMar = 'home_month_mar';
  static const monthApr = 'home_month_apr';
  static const monthMay = 'home_month_may';
  static const monthJun = 'home_month_jun';
  static const monthJul = 'home_month_jul';
  static const monthAug = 'home_month_aug';
  static const monthSep = 'home_month_sep';
  static const monthOct = 'home_month_oct';

  // Weekday abbreviations (weekly chart)
  static const dayMon = 'home_day_mon';
  static const dayTue = 'home_day_tue';
  static const dayWed = 'home_day_wed';
  static const dayThu = 'home_day_thu';
  static const dayFri = 'home_day_fri';

  // Contact page default fallbacks
  static const contactDefaultPhone = 'home_contact_default_phone';
  static const contactDefaultEmail = 'home_contact_default_email';
  static const contactDefaultAddress = 'home_contact_default_address';
  static const contactDefaultHours = 'home_contact_default_hours';

  // Language names & guest account
  static const languageEnglish = 'english';
  static const languagePashto = 'pashto';
  static const languageDari = 'persion_dari';
  static const guestUser = 'guest_user';
  static const tapToLogin = 'tap_to_login';
}

// ═══════════════════════════════════════════
//  SPLASH
// ═══════════════════════════════════════════
abstract final class LSplash {
  static const subtitle1 = 'splash_subtitle_1';
  static const subtitle2 = 'splash_subtitle_2';
  static const subtitle3 = 'splash_subtitle_3';
  static const developedBy = 'splash_developed_by';
  static const onboardingSubtitle = 'onboarding_subtitle';
}

// ═══════════════════════════════════════════
//  LOGIN
// ═══════════════════════════════════════════
abstract final class LLogin {
  static const emailRequired = 'login_email_required';
  static const invalidEmail = 'login_invalid_email';
  static const passwordRequired = 'login_password_required';
  static const min6Chars = 'login_min_6_chars';
  static const invalidCredentials = 'login_invalid_credentials';
  static const badDemoCredentials = 'login_bad_demo_credentials';
  static const demoStudent = 'login_demo_student';
  static const demoParent = 'login_demo_parent';
  static const welcomeBack1 = 'login_welcome_back_1';
  static const welcomeBack2 = 'login_welcome_back_2';
  static const welcomeBack3 = 'login_welcome_back_3';
  static const backToHome = 'login_back_to_home';
  static const emailHint = 'login_email_hint';
  static const passwordHint = 'login_password_hint';
  static const demoAccounts = 'login_demo_accounts';
  static const studentPanels = 'login_student_panels';
  static const student = 'login_student';
  static const parent = 'login_parent';
  static const noAccount = 'no_account';
}

// ═══════════════════════════════════════════
//  SIGNUP
// ═══════════════════════════════════════════
abstract final class LSignup {
  static const nameRequired = 'signup_name_required';
  static const nameMinChars = 'signup_name_min_chars';
  static const emailRequired = 'signup_email_required';
  static const invalidEmail = 'signup_invalid_email';
  static const passwordRequired = 'signup_password_required';
  static const passwordMinChars = 'signup_password_min_chars';
  static const passwordUppercase = 'signup_password_uppercase';
  static const passwordNumber = 'signup_password_number';
  static const accountCreated = 'signup_account_created';
  static const unexpectedError = 'signup_unexpected_error';
  static const createAccount = 'signup_create_account';
  static const nameHint = 'signup_name_hint';
  static const emailHint = 'signup_email_hint';
  static const passwordHint = 'signup_password_hint';
}

// ═══════════════════════════════════════════
//  STUDENT PANEL
// ═══════════════════════════════════════════
abstract final class LStudentPanel {
  static const title = 'sp_title';
  static const eyebrow = 'sp_eyebrow';
  static const welcome = 'sp_welcome';
  static const subtitle = 'sp_subtitle';
  static const courses = 'sp_courses';
  static const assignments = 'sp_assignments';
  static const grades = 'sp_grades';
  static const viewGrades = 'sp_view_grades';
  static const unknown = 'sp_unknown';
  static const teacher = 'sp_teacher';
  static const currentGrades = 'sp_current_grades';
  static const gradesSubtitle = 'sp_grades_subtitle';
  static const details = 'sp_details';
  static const gradeCol = 'sp_grade_col';
  static const scoreCol = 'sp_score_col';
  static const subjectCol = 'sp_subject_col';
  static const statusCol = 'sp_status_col';
  static const noGrades = 'sp_no_grades';
  static const performanceAnalytics = 'sp_performance_analytics';
  static const analyticsSubtitle = 'sp_analytics_subtitle';
  static const gradeTrend = 'sp_grade_trend';
  static const last6Months = 'sp_last_6_months';
  static const assignmentStatus = 'sp_assignment_status';
  static const statusSubtitle = 'sp_status_subtitle';
  static const completed = 'sp_completed';
  static const pending = 'sp_pending';
  static const late = 'sp_late';
  static const submitted = 'sp_submitted';
  static const assignmentWorkflow = 'sp_assignment_workflow';
  static const workflowSubtitle = 'sp_workflow_subtitle';
  static const review = 'sp_review';
  static const reviewSub = 'sp_review_sub';
  static const research = 'sp_research';
  static const researchSub = 'sp_research_sub';
  static const complete = 'sp_complete';
  static const completeSub = 'sp_complete_sub';
  static const submit = 'sp_submit';
  static const submitSub = 'sp_submit_sub';
  static const quickStats = 'sp_quick_stats';
  static const statsSubtitle = 'sp_stats_subtitle';
  static const activeCourses = 'sp_active_courses';
  static const thisSemester = 'sp_this_semester';
  static const pendingAssignments = 'sp_pending_assignments';
  static const needAttention = 'sp_need_attention';
  static const totalGrades = 'sp_total_grades';
  static const recorded = 'sp_recorded';
  static const studentModules = 'sp_student_modules';
  static const mySchedule = 'sp_my_schedule';
  static const exams = 'sp_exams';
  static const results = 'sp_results';
  static const attendance = 'sp_attendance';
  static const resources = 'sp_resources';
  static const certificates = 'sp_certificates';
  static const feeDetails = 'sp_fee_details';
  static const library = 'sp_library';
  static const achievements = 'sp_achievements';
  static const academicHistory = 'sp_academic_history';
  static const studyPlanner = 'sp_study_planner';
  static const onlineClasses = 'sp_online_classes';
  static const careerGuidance = 'sp_career_guidance';
  static const scholarships = 'sp_scholarships';
  static const sports = 'sp_sports';
  static const mentalHealth = 'sp_mental_health';
  static const subjectProgress = 'sp_subject_progress';
  static const notifications = 'sp_notifications';
  static const myProfile = 'sp_my_profile';
  static const studyMaterials = 'sp_study_materials';
  static const feedback = 'sp_feedback';
  static const helpSupport = 'sp_help_support';
  static const privacySecurity = 'sp_privacy_security';
  static const digitalLibrary = 'sp_digital_library';
  static const myDocuments = 'sp_my_documents';
  static const leaveApply = 'sp_leave_apply';
  static const placementTest = 'sp_placement_test';
  static const untitled = 'sp_untitled';
  static const course = 'sp_course';
  static const pendingAssignmentsTitle = 'sp_pending_assignments_title';
  static const pendingAssignmentsSub = 'sp_pending_assignments_sub';
  static const viewAll = 'sp_view_all';
  static const assignmentCol = 'sp_assignment_col';
  static const dueDateCol = 'sp_due_date_col';
  static const priorityCol = 'sp_priority_col';
  static const noPendingAssignments = 'sp_no_pending_assignments';
  static const excellent = 'sp_excellent';
  static const good = 'sp_good';
  static const average = 'sp_average';
  static const needsImprovement = 'sp_needs_improvement';
  static const noDueDate = 'sp_no_due_date';
  static const today = 'sp_today';
  static const tomorrow = 'sp_tomorrow';
  static const overdue = 'sp_overdue';
  static const low = 'sp_low';
  static const high = 'sp_high';
  static const medium = 'sp_medium';
}

// ═══════════════════════════════════════════
//  PARENT PANEL
// ═══════════════════════════════════════════
abstract final class LParentPanel {
  static const title = 'pp_title';
  static const eyebrow = 'pp_eyebrow';
  static const welcomeBack = 'pp_welcome_back';
  static const subtitle = 'pp_subtitle';
  static const children = 'pp_children';
  static const enrolled = 'pp_enrolled';
  static const attendance = 'pp_attendance';
  static const avg = 'pp_avg';
  static const feesDue = 'pp_fees_due';
  static const payFees = 'pp_pay_fees';
  static const contactSchool = 'pp_contact_school';
  static const errorTitle = 'pp_error_title';
  static const errorSub = 'pp_error_sub';
  static const feeProcess = 'pp_fee_process';
  static const feeProcessSub = 'pp_fee_process_sub';
  static const viewInvoice = 'pp_view_invoice';
  static const viewInvoiceSub = 'pp_view_invoice_sub';
  static const selectMethod = 'pp_select_method';
  static const selectMethodSub = 'pp_select_method_sub';
  static const confirm = 'pp_confirm';
  static const confirmSub = 'pp_confirm_sub';
  static const receipt = 'pp_receipt';
  static const receiptSub = 'pp_receipt_sub';
  static const quickActions = 'pp_quick_actions';
  static const myChildren = 'pp_my_children';
  static const feePayment = 'pp_fee_payment';
  static const reportCards = 'pp_report_cards';
  static const noticeBoard = 'pp_notice_board';
  static const meetings = 'pp_meetings';
  static const calendar = 'pp_calendar';
  static const transport = 'pp_transport';
  static const healthRecords = 'pp_health_records';
  static const complaints = 'pp_complaints';
  static const events = 'pp_events';
  static const activities = 'pp_activities';
  static const emergency = 'pp_emergency';
  static const settings = 'pp_settings';
  static const messages = 'pp_messages';
  static const invoices = 'pp_invoices';
  static const documents = 'pp_documents';
  static const performance = 'pp_performance';
  static const childrenPerformance = 'pp_children_performance';
  static const noChildren = 'pp_no_children';
  static const nA = 'pp_n_a';
  static const active = 'pp_active';
  static const currentSemester = 'pp_current_semester';
  static const viewAll = 'pp_view_all';
  static const studentCol = 'pp_student_col';
  static const classCol = 'pp_class_col';
  static const avgGradeCol = 'pp_avg_grade_col';
  static const attendanceCol = 'pp_attendance_col';
  static const statusCol = 'pp_status_col';
  static const noData = 'pp_no_data';
  static const aExcellent = 'pp_a_excellent';
  static const bGood = 'pp_b_good';
  static const cAverage = 'pp_c_average';
  static const dBelow = 'pp_d_below';
  static const noDataSegment = 'pp_no_data_segment';
  static const attendanceTrend = 'pp_attendance_trend';
  static const gradeDistribution = 'pp_grade_distribution';
  static const distributionSub = 'pp_distribution_sub';
  static const upcomingExams = 'pp_upcoming_exams';
  static const nextCheckSchedule = 'pp_next_check_schedule';
  static const none = 'pp_none';
  static const schoolEvents = 'pp_school_events';
  static const thisMonth = 'pp_this_month';
  static const unread = 'pp_unread';
  static const allRead = 'pp_all_read';
  static const recentNotifications = 'pp_recent_notifications';
  static const noNotifications = 'pp_no_notifications';
  static const untitled = 'pp_untitled';
  static const general = 'pp_general';
  static const noDate = 'pp_no_date';
  static const latestUpdates = 'pp_latest_updates';
  static const notificationCol = 'pp_notification_col';
  static const categoryCol = 'pp_category_col';
  static const dateCol = 'pp_date_col';
}

// ═══════════════════════════════════════════
//  APP UPDATE
// ═══════════════════════════════════════════
abstract final class LAppUpdate {
  static const title = 'au_title';
  static const releaseManagement = 'au_release_management';
  static const stayOnLatest = 'au_stay_on_latest';
  static const trackVersion = 'au_track_version';
  static const installed = 'au_installed';
  static const build = 'au_build';
  static const updateCompleted = 'au_update_completed';
  static const checkAgain = 'au_check_again';
  static const currentBuildStatus = 'au_current_build_status';
  static const buildStatusSub = 'au_build_status_sub';
  static const latestRelease = 'au_latest_release';
  static const versionMatch = 'au_version_match';
  static const releaseNotes = 'au_release_notes';
  static const releaseNotesSub = 'au_release_notes_sub';
  static const note1Title = 'au_note_1_title';
  static const note1Desc = 'au_note_1_desc';
  static const note2Title = 'au_note_2_title';
  static const note2Desc = 'au_note_2_desc';
  static const note3Title = 'au_note_3_title';
  static const note3Desc = 'au_note_3_desc';
}

// ═══════════════════════════════════════════
//  BASE PANEL LAYOUT
// ═══════════════════════════════════════════
abstract final class LBasePanel {
  static const comingSoon = 'bp_coming_soon';
  static const underDevelopment = 'bp_under_development';
  static const underConstruction = 'bp_under_construction';
  static const moreOptions = 'bp_more_options';
  static const pagesAvailable = 'bp_pages_available';
  static const profile = 'bp_profile';
  static const mySchedule = 'bp_my_schedule';
  static const chat = 'bp_chat';
  static const messagesHub = 'bp_messages_hub';
  static const notifications = 'bp_notifications';
  static const noticeBoard = 'bp_notice_board';
  static const leaveManagement = 'bp_leave_management';
  static const settings = 'bp_settings';
  static const loggedInDevices = 'bp_logged_in_devices';
  static const appUpdate = 'bp_app_update';
  static const changePassword = 'bp_change_password';
  static const helpSupport = 'bp_help_support';
  static const aboutEmis = 'bp_about_emis';
  static const myPrograms = 'bp_my_programs';
  static const exams = 'bp_exams';
  static const courses = 'bp_courses';
  static const grades = 'bp_grades';
  static const feePayment = 'bp_fee_payment';
  static const results = 'bp_results';
  static const lms = 'bp_lms';
  static const libraryBooks = 'bp_library_books';
  static const assignments = 'bp_assignments';
  static const timetable = 'bp_timetable';
  static const myChildren = 'bp_my_children';
  static const feePayments = 'bp_fee_payments';
  static const messages = 'bp_messages';
}
