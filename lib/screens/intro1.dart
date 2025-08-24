import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sushiaya/screens/button.dart';
import 'package:sushiaya/screens/login.dart';

class intro1 extends StatefulWidget {
  const intro1({super.key});

  @override
  State<intro1> createState() => _intro1State();
}

class _intro1State extends State<intro1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 213, 134, 15),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 200,
            ), // Reduced height to make room for button
            // Logo
            Image.asset("images/sushi-roll.png", width: 100),

            const SizedBox(height: 30),

            // App Title
            Center(
              child: Text(
                'SUSHIAYA',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Subtitle
            Text(
              "THE BEAST JAPANESE FOOD EVER !",
              style: GoogleFonts.lato(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(), // This pushes the button to the bottom area
            // Login Button using SushiayaButton
            SushiayaButton(
              text: "GET STARTED",
              width: double.infinity,
              height: 60,
              borderRadius: 20,
              onPressed: () {
                // Navigate to login screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const LoginScreen(), // Replace with your login screen
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Optional: Add a secondary button for existing users
            SushiayaButton(
              text: "I ALREADY HAVE AN ACCOUNT",
              width: double.infinity,
              height: 50,
              borderRadius: 20,
              isOutlined: true,
              textStyle: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              onPressed: () {
                // Navigate directly to login or show login dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const LoginScreen(), // Replace with your login screen
                  ),
                );
              },
            ),

            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }
}

// Example Login Screen (replace this with your actual login screen)
