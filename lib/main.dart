import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sushiaya/screens/intro1.dart';
import 'firebase_options.dart';
import 'package:sushiaya/providers/cart_provider.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Firebase
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      // For mobile/desktop, rely on platform-specific configuration files
      await Firebase.initializeApp();
    }
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
      child: ChangeNotifierProvider(
        create: (context) => CartProvider(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'Sushiaya',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const IntroScreen(),
    );
  }
}
