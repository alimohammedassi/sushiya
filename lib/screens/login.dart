import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sushiaya/services/firebase_service.dart';
import 'package:sushiaya/screens/button.dart';
import 'package:provider/provider.dart';
import 'package:sushiaya/screens/sign.dart';
import 'package:sushiaya/screens/home.dart';
import 'cartPro.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Add this import for your home page

// LOGIN SCREEN
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final credential = await FirebaseService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (credential != null) {
          print('Login successful - User: ${credential.user?.email}');

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Login successful!',
                style: TextStyle(color: Colors.black54, fontSize: 20),
              ),
              backgroundColor: Color.fromARGB(255, 255, 172, 57),
              duration: Duration(seconds: 1),
            ),
          );

          // Navigate immediately to home screen
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                  create: (context) => CartProvider(),
                  child: const HomeScreen(),
                ),
              ),
              (route) => false,
            );
          }
        } else {
          print('Login failed - No credential returned');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('login.failed'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    final result = await FirebaseService.signInWithGoogle();

    // Check if widget is still mounted before calling setState
    if (mounted) {
      setState(() => _isLoading = false);
      if (result != null) {
        print('Google login successful - User: ${result.user?.email}');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Login successful!',
              style: TextStyle(color: Colors.black54, fontSize: 20),
            ),
            backgroundColor: Color.fromARGB(255, 255, 172, 57),
            duration: Duration(seconds: 1),
          ),
        );

        // Navigate immediately to home screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (context) => CartProvider(),
              child: const HomeScreen(),
            ),
          ),
          (route) => false,
        );
      } else {
        print('Google login failed - No result returned');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('login.google_failed'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 213, 134, 15),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),

                const SizedBox(height: 40),

                // Welcome text
                Text(
                  'login.welcome_back'.tr(),
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'login.sign_in_continue'.tr(),
                  style: GoogleFonts.lato(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 60),

                // Email field
                _buildTextField(
                  controller: _emailController,
                  label: 'login.email'.tr(),
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'login.enter_email'.tr();
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'login.valid_email'.tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password field
                _buildTextField(
                  controller: _passwordController,
                  label: 'login.password'.tr(),
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'login.enter_password'.tr();
                    }
                    if (value.length < 6) {
                      return 'login.password_length'.tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Handle forgot password
                    },
                    child: Text(
                      'login.forgot_password'.tr(),
                      style: GoogleFonts.lato(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Login button
                SushiayaButton(
                  text: "login.login_button".tr(),
                  width: double.infinity,
                  height: 60,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleLogin,
                ),

                const SizedBox(height: 30),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'login.or'.tr(),
                        style: GoogleFonts.lato(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Google Sign-in button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color.fromARGB(255, 225, 6, 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleGoogleLogin,
                    icon: const Icon(Icons.login),
                    label: Text(
                      'Google',
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Sign up button
                SushiayaButton(
                  text: "login.create_account".tr(),
                  width: double.infinity,
                  height: 50,
                  isOutlined: true,
                  textStyle: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Debug button to test authentication
                if (kDebugMode)
                  ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      print('Current user: ${user?.email}');
                      print('Is authenticated: ${user != null}');

                      // Try to sign in anonymously to test Firebase
                      try {
                        final result = await FirebaseAuth.instance
                            .signInAnonymously();
                        print(
                          'Anonymous sign in successful: ${result.user?.uid}',
                        );
                      } catch (e) {
                        print('Anonymous sign in failed: $e');
                      }
                    },
                    child: const Text('Debug: Test Firebase Auth'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.lato(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.lato(color: Colors.white.withOpacity(0.8)),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8)),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white.withOpacity(0.8),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }
}
