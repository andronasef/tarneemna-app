import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:tarneemna/core/values.dart';
import 'package:tarneemna/features/settings/presentation/providers/settings_providers.dart';

import '../screens/home/home_screen.dart';
import '../utils/analytics.dart';
import 'global_controller.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final theme = ref.watch(activeThemeProvider);

    return GetMaterialApp(
      title: AppDetails.kAppName,
      home: const HomeScreen(),
      initialBinding: AppControllerBinder(),
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
      theme: theme,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.fontScale),
          ),
          child: child!,
        );
      },
    );
  }
}
