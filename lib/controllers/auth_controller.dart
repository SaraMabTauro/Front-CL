import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../core/constants.dart';

class AuthController extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];
        
        // Store token securely
        await _storage.write(key: AppConstants.tokenKey, value: token);
        await _storage.write(key: AppConstants.userKey, value: jsonEncode(userData));
        
        _currentUser = User.fromJson(userData);
        _setLoading(false);
        return true;
      } else {
        _setError('Invalid credentials');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error. Please try again.');
      _setLoading(false);
      return false;
    }
  }
  
  Future<bool> register(String firstName, String lastName, String email, String password) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await ApiService.post('/users/register', {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      });
      
      if (response.statusCode == 201) {
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Registration failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error. Please try again.');
      _setLoading(false);
      return false;
    }
  }
  
  Future<void> getUserProfile() async {
    _setLoading(true);
    
    try {
      final response = await ApiService.get('/users/me', requireAuth: true);
      
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        _currentUser = User.fromJson(userData);
      }
    } catch (e) {
      _setError('Failed to load profile');
    }
    
    _setLoading(false);
  }
  
  Future<bool> updateUserProfile(User updatedUser) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await ApiService.put('/users/me', updatedUser.toJson(), requireAuth: true);
      
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        _currentUser = User.fromJson(userData);
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to update profile');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error. Please try again.');
      _setLoading(false);
      return false;
    }
  }
  
  Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userKey);
    _currentUser = null;
    notifyListeners();
  }
  
  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    final userJson = await _storage.read(key: AppConstants.userKey);
    
    if (token != null && userJson != null) {
      try {
        final userData = jsonDecode(userJson);
        _currentUser = User.fromJson(userData);
        notifyListeners();
      } catch (e) {
        await logout();
      }
    }
  }
}
