import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:8000/api'; // iOS simulator
  // static const String baseUrl = 'http://YOUR_LOCAL_IP:8000/api'; // Physical device

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
    final response = await http.post(
      Uri.parse('$baseUrl/token/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }

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

  // Item Methods
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

    // Add headers with auth
    final headers = await _getHeaders();
    request.headers.addAll(headers);

    // Add form fields
    itemData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add image if provided
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
}
