import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';
import '../core/mock_data.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();
  
  static Future<String?> _getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }
  
  static Map<String, String> _getHeaders({bool includeAuth = true}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    return headers;
  }
  
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  static Future<http.Response> post(String endpoint, Map<String, dynamic> body, {bool requireAuth = false}) async {
    // Use mock data if enabled
    if (MockConstants.useMockData) {
      return await MockApiService.post(endpoint, body, requireAuth: requireAuth);
    }
    
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final headers = requireAuth ? await _getAuthHeaders() : _getHeaders();
    
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }
  
  static Future<http.Response> get(String endpoint, {bool requireAuth = false}) async {
    // Use mock data if enabled
    if (MockConstants.useMockData) {
      return await MockApiService.get(endpoint, requireAuth: requireAuth);
    }
    
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final headers = requireAuth ? await _getAuthHeaders() : _getHeaders();
    
    return await http.get(url, headers: headers);
  }
  
  static Future<http.Response> put(String endpoint, Map<String, dynamic> body, {bool requireAuth = false}) async {
    // Use mock data if enabled
    if (MockConstants.useMockData) {
      return await MockApiService.put(endpoint, body, requireAuth: requireAuth);
    }
    
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final headers = requireAuth ? await _getAuthHeaders() : _getHeaders();
    
    return await http.put(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }
}