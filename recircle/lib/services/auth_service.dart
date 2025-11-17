import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _usernameKey = 'username';

  // Save tokens after login
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String username,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, accessToken);
      await prefs.setString(_refreshTokenKey, refreshToken);
      await prefs.setString(_usernameKey, username);
    } catch (e) {
      print('Error saving tokens: $e');
    }
  }

  // Get stored access token
  static Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_accessTokenKey);
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Get current username
  static Future<String?> getUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_usernameKey);
    } catch (e) {
      print('Error getting username: $e');
      return null;
    }
  }

  // Logout - clear all stored data
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_usernameKey);
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}
