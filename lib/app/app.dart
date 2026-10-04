import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:tarneemna/core/values.dart';
import 'package:tarneemna/features/settings/domain/models/app_settings.dart';
import 'package:tarneemna/features/settings/presentation/providers/settings_providers.dart';

import '../screens/home/home_screen.dart';
import '../utils/analytics.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);

    return GetMaterialApp(
      title: AppDetails.kAppName,
      home: const HomeScreen(),
      locale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      defaultTransition: Transition.cupertino,
      navigatorObservers: [analyticsObserver],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''),
      ],
      debugShowCheckedModeBanner: false,
      theme: ref.watch(lightThemeProvider),
      darkTheme: ref.watch(darkThemeProvider),
      themeMode: switch (settings.themeMode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark || AppThemeMode.oled => ThemeMode.dark,
      },
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              // Scale on top of the system accessibility size, don't replace it.
              textScaler: TextScaler.linear(
                MediaQuery.textScalerOf(context).scale(1) * settings.fontScale,
              ),
            ),
            child: child!,
          ),
        );
      },
    );
  }
}
