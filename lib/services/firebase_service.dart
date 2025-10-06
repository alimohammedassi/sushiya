import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Authentication methods
  static FirebaseAuth get auth => _auth;
  static User? get currentUser => _auth.currentUser;

  // User management
  static Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  static Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    try {
      // Also sign out from Google if connected
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (_) {}
  }

  // Google Sign-In
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // user aborted

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error with Google sign-in: $e');
      return null;
    }
  }

  // Admin check
  static bool isAdmin() {
    final user = currentUser;
    if (user == null) return false;

    // Check for admin email
    return user.email == 'admin@sushiaya.com' ||
        user.email == 'aliabouali2005@gmail.com' ||
        user.email?.contains('admin') == true ||
        user.email?.contains('manager') == true;
  }

  // Create admin user if it doesn't exist
  static Future<UserCredential?> createAdminUser() async {
    try {
      // Try to create the admin user
      return await _auth.createUserWithEmailAndPassword(
        email: 'aliabouali2005@gmail.com',
        password: 'aliassi20',
      );
    } catch (e) {
      print('Error creating admin user: $e');
      // If user already exists, try to sign in
      return await signInWithEmailAndPassword(
        'aliabouali2005@gmail.com',
        'aliassi20',
      );
    }
  }
}
