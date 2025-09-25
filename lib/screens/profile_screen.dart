import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sushiaya/services/firebase_service.dart';
import 'package:sushiaya/screens/login.dart';
import 'package:sushiaya/screens/order_history_screen.dart';
import 'package:sushiaya/screens/location_screen.dart';
import 'package:sushiaya/screens/notifications_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  User? currentUser;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isEditingLocation = false;
  bool _isUploadingImage = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  File? _selectedImage;
  String? userLocation;
  String? userPhone;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeUserData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeUserData() {
    currentUser = FirebaseService.currentUser;
    _nameController.text = currentUser?.displayName ?? '';
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingShimmer()
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: 30),
                        _buildProfileForm(),
                        const SizedBox(height: 30),
                        _buildActionButtons(),
                        const SizedBox(height: 20),
                        _buildMenuOptions(),
                        const SizedBox(height: 30),
                        _buildSignOutButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 213, 134, 15),
              Color.fromARGB(255, 255, 165, 40),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Text(
        'profile.title'.tr(),
        style: GoogleFonts.lato(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            // Navigate to settings
          },
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 60),
            const SizedBox(height: 20),
            Container(height: 20, width: 200, color: Colors.white),
            const SizedBox(height: 10),
            Container(height: 16, width: 150, color: Colors.white),
            const SizedBox(height: 30),
            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Container(height: 60, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Hero(
                tag: 'profile_image',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _getProfileImage(),
                    child: _getProfileImage() == null
                        ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                        : null,
                  ),
                ),
              ),
              if (_isUploadingImage)
                Positioned.fill(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.black54,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _isUploadingImage ? null : _showImagePickerOptions,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 213, 134, 15),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currentUser?.displayName ?? 'profile.no_name'.tr(),
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentUser?.email ?? '',
            style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'profile',
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nameController,
          label: 'profile.name'.tr(),
          icon: Icons.person_outline,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'profile.name_required'.tr();
            }
            return null;
          },
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'profile.phone'.tr(),
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^\+?[\d\s-()]+$').hasMatch(value)) {
                return 'profile.phone_invalid'.tr();
              }
            }
            return null;
          },
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        _buildLocationField(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        enabled: enabled,
        style: GoogleFonts.lato(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: const Color.fromARGB(255, 213, 134, 15),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 213, 134, 15),
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[50],
          labelStyle: GoogleFonts.lato(
            color: enabled ? Colors.black87 : Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    213,
                    134,
                    15,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color.fromARGB(255, 213, 134, 15),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'profile.location'.tr(),
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              _buildLocationActions(),
            ],
          ),
          const SizedBox(height: 16),
          _buildLocationContent(),
        ],
      ),
    );
  }

  Widget _buildLocationActions() {
    if (userLocation != null && !_isEditingLocation) {
      return Row(
        children: [
          _buildActionButton(
            icon: Icons.edit_outlined,
            onTap: () => setState(() => _isEditingLocation = true),
            color: const Color.fromARGB(255, 213, 134, 15),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.delete_outline,
            onTap: _showDeleteLocationDialog,
            color: Colors.red,
          ),
        ],
      );
    } else if (_isEditingLocation) {
      return Row(
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                _locationController.text = userLocation ?? '';
                _isEditingLocation = false;
              });
            },
            child: Text(
              'profile.cancel'.tr(),
              style: GoogleFonts.lato(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_locationController.text.trim().isNotEmpty) {
                _saveLocation(_locationController.text.trim());
              }
            },
            child: Text(
              'profile.save'.tr(),
              style: GoogleFonts.lato(
                color: const Color.fromARGB(255, 213, 134, 15),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildLocationContent() {
    if (_isEditingLocation) {
      return TextFormField(
        controller: _locationController,
        decoration: InputDecoration(
          hintText: 'profile.enter_location'.tr(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 213, 134, 15),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: GoogleFonts.lato(fontSize: 14, color: Colors.black87),
        autofocus: true,
      );
    } else if (userLocation != null && userLocation!.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Text(
          userLocation!,
          style: GoogleFonts.lato(fontSize: 14, color: Colors.black87),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _isEditingLocation = true);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.add, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'profile.tap_add_location'.tr(),
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isEditing ? _updateProfile : _enableEditing,
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            label: Text(_isEditing ? 'profile.save'.tr() : 'profile.edit'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 213, 134, 15),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        if (_isEditing) ...[
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _cancelEditing,
              icon: const Icon(Icons.cancel),
              label: Text('profile.cancel'.tr()),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMenuOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'profile.menu'.tr(),
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildMenuTile(
          icon: Icons.history,
          title: 'profile.order_history'.tr(),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
          ),
        ),
        _buildMenuTile(
          icon: Icons.notifications_outlined,
          title: 'profile.notifications'.tr(),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
            ),
          ),
        ),
        _buildMenuTile(
          icon: Icons.language,
          title: 'profile.language'.tr(),
          onTap: _showLanguageSelector,
        ),
        _buildMenuTile(
          icon: Icons.help_outline,
          title: 'profile.help_support'.tr(),
          onTap: () {
            // Navigate to help screen
          },
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 213, 134, 15).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color.fromARGB(255, 213, 134, 15)),
        ),
        title: Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _signOut,
        icon: const Icon(Icons.logout),
        label: Text('profile.sign_out'.tr()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  // Helper Methods

  ImageProvider? _getProfileImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (currentUser?.photoURL != null) {
      return CachedNetworkImageProvider(currentUser!.photoURL!);
    }
    return null;
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocation = prefs.getString('user_location');
      final savedPhone = prefs.getString('user_phone');

      if (mounted) {
        setState(() {
          userLocation = savedLocation;
          userPhone = savedPhone;
          _locationController.text = savedLocation ?? '';
          _phoneController.text = savedPhone ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveLocation(String location) async {
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_location', location);

      if (mounted) {
        setState(() {
          userLocation = location;
          _isEditingLocation = false;
        });

        _showSuccessSnackBar('Location saved successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to save location');
      }
    }
  }

  Future<void> _deleteLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_location');

      if (mounted) {
        setState(() {
          userLocation = null;
          _locationController.clear();
          _isEditingLocation = false;
        });

        _showSuccessSnackBar('profile.location_deleted'.tr());
      }
    } catch (e) {
      _showErrorSnackBar('profile.location_delete_failed'.tr());
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.lato(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showImagePickerOptions() {
    final context = this.context; // Capture context early

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Photo',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageSourceButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color.fromARGB(255, 213, 134, 15),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!mounted) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImage = File(image.path);
          _isUploadingImage = true;
        });

        // Upload to Firebase Storage
        await _uploadProfileImage();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to pick image');
      }
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null || !mounted) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${currentUser!.uid}.jpg');

      final uploadTask = storageRef.putFile(_selectedImage!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await currentUser!.updatePhotoURL(downloadUrl);

      if (mounted) {
        setState(() {
          _isUploadingImage = false;
          currentUser = FirebaseService.currentUser;
        });

        _showSuccessSnackBar('Profile image updated successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        _showErrorSnackBar('Failed to upload image');
      }
    }
  }

  void _enableEditing() {
    HapticFeedback.lightImpact();
    setState(() => _isEditing = true);
  }

  void _cancelEditing() {
    HapticFeedback.lightImpact();
    setState(() {
      _isEditing = false;
      _nameController.text = currentUser?.displayName ?? '';
      _phoneController.text = userPhone ?? '';
    });
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || !mounted) return;

    HapticFeedback.lightImpact();

    setState(() => _isLoading = true);

    try {
      // Update display name
      if (_nameController.text.trim() != currentUser?.displayName) {
        await currentUser?.updateDisplayName(_nameController.text.trim());
      }

      // Save phone number
      if (_phoneController.text.trim() != userPhone) {
        final prefs = await SharedPreferences.getInstance();
        if (_phoneController.text.trim().isNotEmpty) {
          await prefs.setString('user_phone', _phoneController.text.trim());
        } else {
          await prefs.remove('user_phone');
        }
        userPhone = _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null;
      }

      if (mounted) {
        setState(() {
          _isEditing = false;
          currentUser = FirebaseService.currentUser;
        });

        _showSuccessSnackBar('Profile updated successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to update profile');
      }
      debugPrint('Profile update error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
    if (!mounted) return;

    // Store context references before async operations
    final currentContext = context;
    final navigator = Navigator.of(currentContext);
    final messenger = ScaffoldMessenger.of(currentContext);

    final result = await showDialog<bool>(
      context: currentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.lato(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.lato(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Sign Out',
              style: GoogleFonts.lato(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (result != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseService.signOut();

      if (mounted) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Failed to sign out. Please try again.');
      }
      debugPrint('Sign out error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.lato(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showDeleteLocationDialog() {
    if (!mounted) return;

    // Store context reference before async operations
    final currentContext = context;
    final messenger = ScaffoldMessenger.of(currentContext);

    showDialog(
      context: currentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Location',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete your location?',
          style: GoogleFonts.lato(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.lato(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_location');

                if (mounted) {
                  setState(() {
                    userLocation = null;
                    _locationController.clear();
                    _isEditingLocation = false;
                  });

                  _showSuccessSnackBar('Location deleted successfully');
                }
              } catch (e) {
                if (mounted) {
                  _showErrorSnackBar('Failed to delete location');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.lato(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    // Get supported locales from EasyLocalization and capture context
    if (!mounted) return;
    final currentContext = context;
    final supportedLocales = currentContext.supportedLocales;

    showModalBottomSheet(
      context: currentContext,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Language',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Dynamically build language tiles based on supported locales
            ...supportedLocales.map((locale) => _buildLanguageTile(locale)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile(Locale locale) {
    if (!mounted) return const SizedBox.shrink();

    final isSelected = context.locale == locale;

    // Define language info based on locale
    String title;
    String flag;

    switch (locale.languageCode) {
      case 'en':
        title = 'English';
        flag = '🇺🇸';
        break;
      case 'ar':
        title = 'العربية';
        flag = '🇪🇬';
        break;
      case 'es':
        title = 'Español';
        flag = '🇪🇸';
        break;
      case 'fr':
        title = 'Français';
        flag = '🇫🇷';
        break;
      case 'de':
        title = 'Deutsch';
        flag = '🇩🇪';
        break;
      case 'ja':
        title = '日本語';
        flag = '🇯🇵';
        break;
      case 'ko':
        title = '한국어';
        flag = '🇰🇷';
        break;
      case 'zh':
        title = '中文';
        flag = '🇨🇳';
        break;
      default:
        title = locale.languageCode.toUpperCase();
        flag = '🌐';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(flag, style: const TextStyle(fontSize: 24)),
        title: Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? const Color.fromARGB(255, 213, 134, 15)
                : Colors.black87,
          ),
        ),
        trailing: isSelected
            ? const Icon(
                Icons.check_circle,
                color: Color.fromARGB(255, 213, 134, 15),
              )
            : null,
        onTap: () async {
          if (!mounted) return;

          HapticFeedback.lightImpact();

          // Store context before async operations
          final currentContext = context;
          final navigator = Navigator.of(currentContext);
          final messenger = ScaffoldMessenger.of(currentContext);

          navigator.pop();

          try {
            await currentContext.setLocale(locale);
            if (mounted) {
              _showSuccessSnackBar('Language changed successfully');
            }
          } catch (e) {
            debugPrint('Error changing language: $e');
            if (mounted) {
              _showErrorSnackBar('Failed to change language');
            }
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected
            ? const Color.fromARGB(255, 213, 134, 15).withOpacity(0.1)
            : Colors.transparent,
      ),
    );
  }
}
