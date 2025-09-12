import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/widgets/auth_wrapper.dart';
import 'features/social/presentation/bloc/social_bloc.dart';
import 'core/injection/injection_container.dart' as di;
import 'core/services/logger_service.dart';
import 'core/constants/app_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/auth/presentation/pages/settings/privacy_policy_page.dart';
import 'features/auth/presentation/pages/settings/terms_of_service_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger
  logger.init();

  await Supabase.initialize(
    url: 'https://qvlurdcrckbmzpyvntip.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF2bHVyZGNyY2tibXpweXZudGlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA0MTA0NTksImV4cCI6MjA2NTk4NjQ1OX0.TSzAsqH72wtlrT6AcfN9s__RYjDuIrzaORSCnZRZyxQ',
  );

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize dependency injection
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<SocialBloc>(),
      child: MaterialApp(
        title: AppConstants.appName,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', 'US'), Locale('id', 'ID')],
        routes: {
          '/privacy': (context) => const PrivacyPolicyPage(),
          '/terms': (context) => const TermsOfServicePage(),
        },
        onGenerateRoute: (settings) {
          // Handle deep linking
          if (settings.name?.startsWith('/auth/callback') ?? false) {
            return MaterialPageRoute(builder: (_) => const AuthWrapper());
          }
          // Handle login-callback
          if (settings.name?.startsWith('/login-callback') ?? false) {
            return MaterialPageRoute(builder: (_) => const AuthWrapper());
          }
          return null;
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (_) => const AuthWrapper());
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7AC142), // Green color similar to logo
            primary: const Color(0xFF7AC142),
            secondary: const Color(0xFF5A9A2A),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF7AC142),
            foregroundColor: Colors.white,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF7AC142),
            foregroundColor: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
