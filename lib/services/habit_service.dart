import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitService extends ChangeNotifier {
  List<Habit> _habits = [];
  bool _isLoading = false;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;

  // Constructor
  HabitService() {
    // Inicializar los hábitos con datos de ejemplo (puedes quitar esto)
    _habits = [
      Habit(id: '1', name: 'Leer 30 minutos', description: 'Leer un libro durante 30 minutos cada día.', frequency: 'Diaria', target: 30, currentProgress: 15, unit: 'minutos'),
      Habit(id: '2', name: 'Caminar 5 km', description: 'Caminar 5 kilómetros cada día.', frequency: 'Diaria', target: 5, currentProgress: 2, unit: 'km'),
    ];
  }

  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    // Simular una llamada a la API (reemplaza esto con tu lógica real)
    await Future.delayed(const Duration(seconds: 1));

    // Aquí iría la lógica para obtener los hábitos de la API
    // Por ahora, usamos datos de ejemplo
    _habits = [
      Habit(id: '1', name: 'Leer 30 minutos', description: 'Leer un libro durante 30 minutos cada día.', frequency: 'Diaria', target: 30, currentProgress: 15, unit: 'minutos'),
      Habit(id: '2', name: 'Caminar 5 km', description: 'Caminar 5 kilómetros cada día.', frequency: 'Diaria', target: 5, currentProgress: 2, unit: 'km'),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Habit? getHabitById(String id) {
    try{
        return _habits.firstWhere((habit) => habit.id == id);
    }catch(e){
      return null;
    }
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    notifyListeners();
  }

  void deleteHabit(String id) {
    _habits.removeWhere((habit) => habit.id == id);
    notifyListeners();
  }
}