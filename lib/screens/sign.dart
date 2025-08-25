import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sushiaya/screens/button.dart';
import 'package:sushiaya/services/firebase_service.dart';
import 'package:easy_localization/easy_localization.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('signup.accept_terms'.tr()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final credential = await FirebaseService.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Update user profile with name if account creation was successful
      if (credential != null && credential.user != null) {
        try {
          await credential.user!.updateDisplayName(_nameController.text.trim());
        } catch (e) {
          print('Error updating display name: $e');
        }
      }

      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (credential != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('signup.account_created'.tr()),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
          // AuthGate will handle navigation automatically
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('signup.failed'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
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

                const SizedBox(height: 30),

                // Welcome text
                Text(
                  'signup.join_sushiaya'.tr(),
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'signup.create_account_start'.tr(),
                  style: GoogleFonts.lato(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                // Full Name field
                _buildTextField(
                  controller: _nameController,
                  label: 'signup.full_name'.tr(),
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'signup.enter_name'.tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Email field
                _buildTextField(
                  controller: _emailController,
                  label: 'signup.email'.tr(),
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'signup.enter_email'.tr();
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'signup.valid_email'.tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Phone field
                _buildTextField(
                  controller: _phoneController,
                  label: 'signup.phone'.tr(),
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'signup.enter_phone'.tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password field
                _buildTextField(
                  controller: _passwordController,
                  label: 'signup.password'.tr(),
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isPasswordVisible: _isPasswordVisible,
                  onVisibilityToggle: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'signup.enter_password'.tr();
                    }
                    if (value.length < 6) {
                      return 'signup.password_length'.tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Confirm Password field
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'signup.confirm_password'.tr(),
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isPasswordVisible: _isConfirmPasswordVisible,
                  onVisibilityToggle: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'signup.confirm_password_text'.tr();
                    }
                    if (value != _passwordController.text) {
                      return 'signup.passwords_not_match'.tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Terms and conditions
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                      activeColor: Colors.white,
                      checkColor: const Color.fromARGB(255, 213, 134, 15),
                      side: const BorderSide(color: Colors.white),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _acceptTerms = !_acceptTerms;
                          });
                        },
                        child: Text(
                          'signup.terms_conditions'.tr(),
                          style: GoogleFonts.lato(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Sign up button
                SushiayaButton(
                  text: "signup.create_account".tr(),
                  width: double.infinity,
                  height: 60,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleSignUp,
                ),

                const SizedBox(height: 30),

                // Login link
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.lato(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(text: "signup.already_account".tr()),
                          TextSpan(
                            text: "signup.login".tr(),
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
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
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
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
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.lato(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.lato(color: Colors.white.withOpacity(0.8)),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8)),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: onVisibilityToggle,
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
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
