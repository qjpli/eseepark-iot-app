// UPDATED LINKED
import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:eseepark/providers/general/theme_provider.dart';
import 'package:eseepark/providers/root_provider.dart';
import 'package:eseepark/screens/general/get_started.dart';
import 'package:eseepark/screens/others/hub.dart';
import 'package:eseepark/screens/others/lobby/account_name.dart';
import 'package:eseepark/screens/others/lobby/lobby.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'globals.dart' as globals;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Supabase.initialize(
    url: 'https://pqxkrecuksyiuaoxcuyx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBxeGtyZWN1a3N5aXVhb3hjdXl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk0MjIxMDEsImV4cCI6MjA1NDk5ODEwMX0.wp_3D6Ha2OyqFZFwRzPD2fArWE4L6EYDpFBzYgjTsi8',
  );

  if(false ?? Platform.isAndroid) {
    runApp(
      DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) =>  MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => RootProvider()),
          ],
          child: const Start(),
        ), // Wrap your app
      )
    );
  } else {
    runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => RootProvider()),
          ],
          child: const Start(),
        )
    );
  }

}

final supabase = Supabase.instance.client;

class Start extends StatelessWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    globals.screenHeight = MediaQuery.of(context).size.height;
    globals.screenWidth = MediaQuery.of(context).size.width;
    globals.screenSize = globals.screenHeight + globals.screenWidth;

    final rootProvider = Provider.of<RootProvider>(context);
    rootProvider.initializeData();


  if (!rootProvider.getGeneralProvider.isInitialized) {
    print('Getting value of: ${rootProvider.getGeneralProvider.isInitialized}');
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.green)),
        ),
      );
    }


  if(false ?? Platform.isAndroid) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: themeProvider.currentTheme.copyWith(
        textTheme: themeProvider.currentTheme.textTheme.apply(
          fontFamily: 'Poppins',
        ),
      ),
      home: rootProvider.getGeneralProvider.isGetStartedShown ? supabase.auth.currentUser != null ? (supabase.auth.currentUser?.userMetadata?['name'] != null ? const Hub() : const AccountName()) : const Lobby() : GetStarted(),
    );
  } else {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme.copyWith(
        textTheme: themeProvider.currentTheme.textTheme.apply(
          fontFamily: 'Poppins',
        ),
      ),
      home: rootProvider.getGeneralProvider.isGetStartedShown ? supabase.auth.currentUser != null ? (supabase.auth.currentUser?.userMetadata?['name'] != null ? const Hub() : const AccountName()) : const Lobby() : GetStarted(),
    );
  }


  }
}

