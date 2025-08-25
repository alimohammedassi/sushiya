import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sushiaya/screens/button.dart';
import 'package:sushiaya/auth/auth_gate.dart';
import 'package:easy_localization/easy_localization.dart';

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
            const SizedBox(height: 60),

            // Language Selector at the top
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value:
                        '${context.locale.languageCode}-${context.locale.countryCode}',
                    dropdownColor: const Color.fromARGB(255, 213, 134, 15),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white.withOpacity(0.9),
                      size: 20,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'en-US',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🇺🇸', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              'English',
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'ar-SA',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🇸🇦', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              'العربية',
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (String? newValue) async {
                      if (newValue != null) {
                        Locale newLocale;
                        if (newValue == 'en-US') {
                          newLocale = Locale('en', 'US');
                        } else if (newValue == 'ar-SA') {
                          newLocale = Locale('ar', 'SA');
                        } else {
                          newLocale = Locale('en', 'US'); // fallback
                        }

                        await context.setLocale(newLocale);
                        setState(() {});
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 120),

            // Logo
            Image.asset("images/sushi-roll.png", width: 100),

            const SizedBox(height: 30),

            // App Title
            Center(
              child: Text(
                ("intro1.app_title".tr()),
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
              ("intro1.subtitle".tr()),
              style: GoogleFonts.lato(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // Login Button using SushiayaButton
            SushiayaButton(
              text: ("intro1.get_started".tr()),
              width: double.infinity,
              height: 60,
              borderRadius: 20,
              onPressed: () {
                // Navigate to AuthGate (which will show login if not authenticated, or home if authenticated)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthGate()),
                );
              },
            ),

            const SizedBox(height: 20),

            // Optional: Add a secondary button for existing users
            SushiayaButton(
              text: ("intro1.have_account".tr()),
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
                // Navigate to AuthGate (which will show login if not authenticated, or home if authenticated)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthGate()),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
