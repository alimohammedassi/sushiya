import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _locationKey = 'user_location';

  /// Save user location to local storage
  static Future<bool> saveLocation(String location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_locationKey, location);
    } catch (e) {
      print('Error saving location: $e');
      return false;
    }
  }

  /// Get saved user location from local storage
  static Future<String?> getLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_locationKey);
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Delete user location from local storage
  static Future<bool> deleteLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_locationKey);
    } catch (e) {
      print('Error deleting location: $e');
      return false;
    }
  }

  /// Check if location exists
  static Future<bool> hasLocation() async {
    try {
      final location = await getLocation();
      return location != null && location.isNotEmpty;
    } catch (e) {
      print('Error checking location: $e');
      return false;
    }
  }

  /// Validate location string (basic validation)
  static bool isValidLocation(String location) {
    if (location.trim().isEmpty) return false;
    if (location.length < 2) return false;
    if (location.length > 100) return false;
    
    // Basic validation - should contain at least some letters
    final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(location);
    return hasLetters;
  }

  /// Format location for display (capitalize first letter of each word)
  static String formatLocation(String location) {
    if (location.isEmpty) return location;
    
    return location
        .split(' ')
        .map((word) => word.isEmpty 
            ? word 
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}