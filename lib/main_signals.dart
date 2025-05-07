import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/core/routes/app_router.dart';
import 'package:nicotinaai_flutter/core/services/service_locator.dart';
import 'package:nicotinaai_flutter/core/services/theme_service.dart';
import 'package:nicotinaai_flutter/core/services/locale_service.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  
  // Initialize application services
  await serviceLocator.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouter _appRouter;
  
  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter();
  }
  
  @override
  Widget build(BuildContext context) {
    return ServicesProvider(
      child: SignalBuilder(
        signal: themeService.themeMode, 
        builder: (context, themeMode) {
          return SignalBuilder(
            signal: localeService.currentLocale,
            builder: (context, locale) {
              return MaterialApp.router(
                title: 'NicotinaAI',
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                  useMaterial3: true,
                ),
                darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.blue,
                    brightness: Brightness.dark,
                  ),
                ),
                themeMode: themeMode,
                locale: locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                routerConfig: _appRouter.router,
              );
            },
          );
        },
      ),
    );
  }
  
  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }
}