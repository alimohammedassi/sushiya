import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sushiaya/screens/main_navigation.dart';
import 'package:sushiaya/screens/login.dart';

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
          return const MainNavigationScreen();
        }

        print('AuthGate - No user authenticated, showing LoginScreen');
        return const LoginScreen();
      },
    );
  }
}
