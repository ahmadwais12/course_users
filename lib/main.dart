import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:course_users/nav.dart';
import 'package:course_users/theme.dart';
import 'package:course_users/config/supabase_config.dart';
import 'package:course_users/l10n/app_localizations.dart';
import 'package:course_users/core/deep_link/deep_link_service.dart';
import 'package:course_users/core/deep_link/widgets/deep_link_handler.dart';
import 'package:course_users/screens/call_screen.dart';
import 'package:course_users/services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  await AdService.instance.init();

  final deepLinkService = DeepLinkService();
  await deepLinkService.init();

  runApp(
    ProviderScope(
      overrides: [
        deepLinkServiceProvider.overrideWithValue(deepLinkService),
      ],
      child: const CourseUsersApp(),
    ),
  );
}

class CourseUsersApp extends ConsumerWidget {
  const CourseUsersApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final textDirection = ref.watch(textDirectionProvider);
    final locale = ref.watch(localeProvider);

    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width >= 1024;

    return Directionality(
      textDirection: textDirection,
      child: ScreenUtilInit(
        designSize: isDesktop ? const Size(1440, 900) : const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        useInheritedMediaQuery: true,
        builder: (context, child) {
          return ResponsiveBreakpoints.builder(
            breakpoints: [
              const Breakpoint(start: 0, end: 599, name: MOBILE),
              const Breakpoint(start: 600, end: 1023, name: TABLET),
              const Breakpoint(start: 1024, end: 1439, name: DESKTOP),
              const Breakpoint(start: 1440, end: 1919, name: 'LARGE'),
              const Breakpoint(start: 1920, end: double.infinity, name: 'ULTRA_WIDE'),
            ],
            child: MaterialApp.router(
              title: 'Course Users - EMIS Portal',
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: ref.watch(themeModeProvider),
              locale: Locale(locale),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('fa'),
                Locale('ps'),
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                if (locale == null) return const Locale('en');
                final lang = locale.languageCode == 'prs' ? 'fa' : locale.languageCode;
                for (final supported in supportedLocales) {
                  if (supported.languageCode == lang) return supported;
                }
                return const Locale('en');
              },
              routerConfig: router,
              builder: (context, child) {
                return Directionality(
                  textDirection: textDirection,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: Theme.of(context).brightness == Brightness.dark
                          ? AppGradients.darkBackground
                          : AppGradients.lightBackground,
                    ),
                    child: IncomingCallListenerWidget(
                      child: DeepLinkHandler(
                        child: child ?? const SizedBox.shrink(),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
