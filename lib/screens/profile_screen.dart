import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sushiaya/services/firebase_service.dart';
import 'package:sushiaya/screens/login.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseService.currentUser;
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 213, 134, 15),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'profile.title'.tr(),
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color.fromARGB(255, 213, 134, 15),
                      backgroundImage: currentUser?.photoURL != null
                          ? NetworkImage(currentUser!.photoURL!)
                          : null,
                      child: currentUser?.photoURL == null
                          ? Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),

                    const SizedBox(height: 20),

                    // User Name
                    Text(
                      currentUser?.displayName ?? 'profile.no_name'.tr(),
                      style: GoogleFonts.lato(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Email
                    Text(
                      currentUser?.email ?? 'profile.no_email'.tr(),
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Account Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'profile.verified'.tr(),
                            style: GoogleFonts.lato(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Profile Options
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Edit Profile
                    _buildProfileOption(
                      icon: Icons.edit,
                      title: 'profile.edit_profile'.tr(),
                      subtitle: 'profile.edit_profile_desc'.tr(),
                      onTap: () {
                        // TODO: Navigate to edit profile screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('profile.edit_coming_soon'.tr()),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                    ),

                    const Divider(height: 1),

                    // Account Settings
                    _buildProfileOption(
                      icon: Icons.settings,
                      title: 'profile.settings'.tr(),
                      subtitle: 'profile.settings_desc'.tr(),
                      onTap: () {
                        // TODO: Navigate to settings screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('profile.settings_coming_soon'.tr()),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                    ),

                    const Divider(height: 1),

                    // Help & Support
                    _buildProfileOption(
                      icon: Icons.help_outline,
                      title: 'profile.help_support'.tr(),
                      subtitle: 'profile.help_support_desc'.tr(),
                      onTap: () {
                        // TODO: Navigate to help screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('profile.help_coming_soon'.tr()),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                    ),

                    const Divider(height: 1),

                    // Sign Out
                    _buildProfileOption(
                      icon: Icons.logout,
                      title: 'profile.sign_out'.tr(),
                      subtitle: 'profile.sign_out_desc'.tr(),
                      onTap: _signOut,
                      isDestructive: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // App Version
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? Colors.red
            : const Color.fromARGB(255, 213, 134, 15),
        size: 24,
      ),
      title: Text(
        title,
        style: GoogleFonts.lato(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.lato(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey[400],
        size: 16,
      ),
      onTap: _isLoading ? null : onTap,
    );
  }
}
