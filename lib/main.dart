import 'dart:async';
import 'dart:ui';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/app_database.dart';
import 'package:nameless_ai/data/providers/api_provider_manager.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/data/providers/chat_session_manager.dart';
import 'package:nameless_ai/data/providers/system_prompt_template_manager.dart';
import 'package:nameless_ai/router/app_router.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/error/error_screen.dart';
import 'package:nameless_ai/utils/app_theme.dart';

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      _showErrorScreen(details.exception, details.stack ?? StackTrace.current);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _showErrorScreen(error, stack);
      return true;
    };

    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    await AppDatabase.registerAdapters();
    await AppDatabase.openBoxes();

    runApp(const MyApp());
  }, (error, stack) {
    _showErrorScreen(error, stack);
  });
}

void _showErrorScreen(Object error, StackTrace stackTrace) {
  runApp(ErrorApp(error: error, stackTrace: stackTrace, onRestart: main));
}

class ErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;
  final VoidCallback onRestart;

  const ErrorApp({
    super.key,
    required this.error,
    required this.stackTrace,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final appConfig = AppConfigProvider();

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (appConfig.enableMonet &&
            lightDynamic != null &&
            darkDynamic != null) {
          lightColorScheme = lightDynamic;
          darkColorScheme = darkDynamic;
        } else {
          lightColorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
          darkColorScheme = ColorScheme.fromSeed(
              seedColor: Colors.blue, brightness: Brightness.dark);
        }

        return MaterialApp(
          title: 'NamelessAI Error',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(lightColorScheme, appConfig.cornerRadius),
          darkTheme:
              AppTheme.darkTheme(darkColorScheme, appConfig.cornerRadius),
          themeMode: appConfig.themeMode,
          locale: appConfig.locale,
          home: ErrorScreen(
            error: error,
            stackTrace: stackTrace,
            onRestart: onRestart,
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppConfigProvider()),
        ChangeNotifierProvider(create: (_) => APIProviderManager()),
        ChangeNotifierProxyProvider<APIProviderManager, ChatSessionManager>(
          create: (context) => ChatSessionManager(),
          update: (context, apiManager, sessionManager) =>
              sessionManager!..setApiProviderManager(apiManager),
        ),
        ChangeNotifierProvider(create: (_) => SystemPromptTemplateManager()),
      ],
      child: Consumer<AppConfigProvider>(
        builder: (context, appConfig, child) {
          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              ColorScheme lightColorScheme;
              ColorScheme darkColorScheme;

              if (appConfig.enableMonet &&
                  lightDynamic != null &&
                  darkDynamic != null) {
                lightColorScheme = lightDynamic;
                darkColorScheme = darkDynamic;
              } else {
                lightColorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
                darkColorScheme = ColorScheme.fromSeed(
                    seedColor: Colors.blue, brightness: Brightness.dark);
              }

              return Builder(builder: (context) {
                final isDarkMode =
                    MediaQuery.platformBrightnessOf(context) == Brightness.dark;
                SystemChrome.setSystemUIOverlayStyle(
                  SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness:
                        isDarkMode ? Brightness.light : Brightness.dark,
                    systemNavigationBarColor: Colors.transparent,
                    systemNavigationBarDividerColor: Colors.transparent,
                    systemNavigationBarIconBrightness:
                        isDarkMode ? Brightness.light : Brightness.dark,
                  ),
                );
                return MaterialApp.router(
                  title: 'NamelessAI',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme(
                      lightColorScheme, appConfig.cornerRadius),
                  darkTheme: AppTheme.darkTheme(
                      darkColorScheme, appConfig.cornerRadius),
                  themeMode: appConfig.themeMode,
                  locale: appConfig.locale,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: AppLocalizations.supportedLocales,
                  routerConfig: AppRouter.getRouter(context),
                );
              });
            },
          );
        },
      ),
    );
  }
}
