import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

class TaskController extends ChangeNotifier {
  List<TaskAssignment> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<TaskAssignment> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  List<TaskAssignment> get pendingTasks => 
      _tasks.where((task) => task.status == 'PENDING').toList();
  
  List<TaskAssignment> get completedTasks => 
      _tasks.where((task) => task.status == 'COMPLETED').toList();
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  Future<void> getTasks() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await ApiService.get('/tasks', requireAuth: true);
      
      if (response.statusCode == 200) {
        final List<dynamic> tasksJson = jsonDecode(response.body);
        _tasks = tasksJson.map((json) => TaskAssignment.fromJson(json)).toList();
      } else {
        _setError('Failed to load tasks');
      }
    } catch (e) {
      _setError('Network error. Please try again.');
    }
    
    _setLoading(false);
  }
  
  Future<bool> completeTask(int assignmentId, TaskFeedback feedbackData) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await ApiService.post(
        '/tasks/$assignmentId/complete',
        feedbackData.toJson(),
        requireAuth: true,
      );
      
      if (response.statusCode == 200) {
        final updatedTaskJson = jsonDecode(response.body);
        final updatedTask = TaskAssignment.fromJson(updatedTaskJson);
        
        // Update the task in the list
        final index = _tasks.indexWhere((task) => task.id == assignmentId);
        if (index != -1) {
          _tasks[index] = updatedTask;
          notifyListeners();
        }
        
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to complete task');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error. Please try again.');
      _setLoading(false);
      return false;
    }
  }
}
