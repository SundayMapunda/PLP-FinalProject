import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Smart base URL detection for different platforms
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api'; // Android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:8000/api'; // iOS simulator
    } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      // For Linux/Windows/Mac desktop, use localhost or your machine's IP
      return 'http://localhost:8000/api'; // Change to your IP if needed
    } else {
      return 'http://localhost:8000/api'; // Fallback
    }
  }

  // Helper method to get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  // Authentication Methods
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('Attempting login to: $baseUrl/token/'); // Debug

      final response = await http
          .post(
            Uri.parse('$baseUrl/token/'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 10)); // Add timeout

      print('Login response status: ${response.statusCode}'); // Debug
      print('Login response body: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Login failed: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception(
        'Network error: Cannot connect to server. Is Django running? $e',
      );
    } on HttpException catch (e) {
      throw Exception('HTTP error: $e');
    } on FormatException catch (e) {
      throw Exception('Response format error: $e');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ... keep the rest of your methods (register, fetchItems, createItem) the same
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Registration failed: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/items/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load items: ${response.statusCode}');
    }
  }

  Future<dynamic> createItem(
    Map<String, dynamic> itemData,
    List<int>? imageBytes,
  ) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/items/'));

    final headers = await _getHeaders();
    request.headers.addAll(headers);

    itemData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'item_image.jpg',
        ),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return json.decode(responseBody);
    } else {
      throw Exception('Failed to create item: ${response.statusCode}');
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user profile: ${response.statusCode}');
    }
  }

  // Get user's items
  Future<List<dynamic>> getUserItems(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/items/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user items: ${response.statusCode}');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> userData,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/update_me/'),
      headers: await _getHeaders(),
      body: json.encode(userData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
  }
}
