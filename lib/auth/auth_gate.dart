import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sushiaya/screens/home.dart';
import 'package:sushiaya/screens/login.dart';
import 'package:sushiaya/screens/cartPro.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Debug print to see what's happening
        print('AuthGate - Connection State: ${snapshot.connectionState}');
        print('AuthGate - Has Data: ${snapshot.hasData}');
        print('AuthGate - User: ${snapshot.data?.email}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if user is authenticated
        if (snapshot.hasData && snapshot.data != null) {
          print('AuthGate - User authenticated, navigating to HomeScreen');
          return ChangeNotifierProvider(
            create: (_) => CartProvider(),
            child: const HomeScreen(),
          );
        }

        print('AuthGate - No user authenticated, showing LoginScreen');
        return const LoginScreen();
      },
    );
  }
}
