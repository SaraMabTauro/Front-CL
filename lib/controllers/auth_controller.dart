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

  Future<bool> login(String correo, String contrasena) async {
    _setLoading(true);
    _setError(null);
    print("$correo $contrasena");
    try {
      final response = await ApiService.post('/usuario/login', {
        'correo': correo,
        'contrasena': contrasena,
      });
      print("Response: ${response.body}");
      print(response.statusCode);
      if (response.statusCode == 201) {
        print("jalo");
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['usuario'];

        // Store token securely
        await _storage.write(key: AppConstants.tokenKey, value: token);
        await _storage.write(
          key: AppConstants.userKey,
          value: jsonEncode(userData),
        );

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

  Future<bool> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
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

  Future<User?> registerClient({
    required String correo,
    required String username,
    required String contrasena,
    required String nombre,
    required String apellido,
    required String rol,
    required int idPsicologo,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.post('/usuario', {
        'correo': correo,
        'username': username,
        'contrasena': contrasena,
        'nombre': nombre,
        'apellido': apellido,
        'rol': rol,
        'idPsicologo': idPsicologo,
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _setLoading(false);
        return User.fromJson(data);
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Error al crear cliente');
        _setLoading(false);
        return null;
      }
    } catch (e) {
      _setError('Error de conexión. Intente nuevamente.');
      _setLoading(false);
      return null;
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
      final endpoint = "/usuario/${updatedUser.id}";
      final response = await ApiService.patch(
        endpoint,
        updatedUser.toJson(),
        requireAuth: true,
      );

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

  Future<List<User>> getAllUsers() async {
    try {
      final response = await ApiService.get('/usuario');
      if (response.statusCode == 200) {
        final List<dynamic> usersJson = jsonDecode(response.body);
        return usersJson.map((json) => User.fromJson(json)).toList();
      } else {
        _setError('No se pudieron obtener los usuarios');
        return [];
      }
    } catch (e) {
      _setError('Error de conexión');
      return [];
    }
  }

  Future<User?> getUserById(int id) async {
  try {
    final response = await ApiService.get('/usuario/$id');
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      _setError('No se encontró el usuario');
      return null;
    }
  } catch (e) {
    _setError('Error de conexión');
    return null;
  }
}

}
