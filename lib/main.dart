import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sushiaya/screens/intro1.dart';
import 'firebase_options.dart';
import 'package:sushiaya/screens/cartPro.dart';
import 'package:sushiaya/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Firebase (only if not already initialized)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase might already be initialized, continue
    print('Firebase initialization: $e');
  }

  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en', 'US'), // English
        Locale('ar', 'SA'), // Arabic
      ],
      path: 'assets/translations', // Path to your translation files
      fallbackLocale: Locale('en', 'US'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        title: 'Sushiaya',
        theme: ThemeData(primarySwatch: Colors.orange),
        home: const intro1(),
      ),
    );
  }
}
