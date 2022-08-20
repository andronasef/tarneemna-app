import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/home/home_screen.dart';
import '../utils/analytics.dart';
import 'global_controller.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'ترانيمنا',
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
        theme: ThemeData(
            colorSchemeSeed: const Color(0xffFF5432),
            textTheme: GoogleFonts.cairoTextTheme()));
  }
}
