import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aula/app/router/app_router.dart';
import 'package:aula/app/theme/app_theme.dart';
import 'package:aula/app/theme/theme_provider.dart';
import 'package:aula/core/services/backup_service.dart';
import 'package:aula/core/services/security_service.dart';
import 'package:aula/l10n/generated/app_localizations.dart';

class AulaApp extends ConsumerStatefulWidget {
  const AulaApp({super.key});

  @override
  ConsumerState<AulaApp> createState() => _AulaAppState();
}

class _AulaAppState extends ConsumerState<AulaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(appLockProvider.notifier).onAppPaused();
      // Trigger silent rotating backup
      ref.read(backupServiceProvider).createRotatingLocalBackup();
    } else if (state == AppLifecycleState.resumed) {
      ref.read(appLockProvider.notifier).onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Aula',
      debugShowCheckedModeBanner: false,
      themeMode: themeState.themeMode,
      theme: AppTheme.lightTheme(accent: themeState.accentColor),
      darkTheme: AppTheme.darkTheme(accent: themeState.accentColor),
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final clampedScaler = mediaQuery.textScaler.clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.6,
        );

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: clampedScaler,
            disableAnimations: themeState.reduceMotion || mediaQuery.disableAnimations,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
