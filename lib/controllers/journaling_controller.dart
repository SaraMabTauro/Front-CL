import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/individual_log_model.dart';
import '../models/interaction_log_model.dart';
import '../services/api_service.dart';

class JournalingController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _errorMessage = error;
    _successMessage = null;
    notifyListeners();
  }
  
  void _setSuccess(String? message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }
  
  Future<bool> submitIndividualLog(IndividualEmotionalLog logData) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await ApiService.post(
        '/journaling/individual-log',
        logData.toJson(),
        requireAuth: true,
      );
      
      if (response.statusCode == 201) {
        _setSuccess('Individual log submitted successfully!');
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Failed to submit log');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error. Please try again.');
      _setLoading(false);
      return false;
    }
  }
  
  Future<bool> submitInteractionLog(InteractionLog logData) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await ApiService.post(
        '/journaling/interaction-log',
        logData.toJson(),
        requireAuth: true,
      );
      
      if (response.statusCode == 201) {
        _setSuccess('Interaction log submitted successfully!');
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Failed to submit log');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error. Please try again.');
      _setLoading(false);
      return false;
    }
  }
  
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
