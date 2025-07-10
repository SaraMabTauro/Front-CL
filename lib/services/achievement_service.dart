import 'package:flutter/material.dart';
import '../models/achievement.dart';

class AchievementService extends ChangeNotifier {
  List<Achievement> _achievements = [];
  bool _isLoading = false;

  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;

  // Constructor
  AchievementService() {
    // Inicializar los logros con datos de ejemplo (puedes quitar esto)
    _achievements = [
      Achievement(id: '1', name: 'Primer Hábito', description: 'Creaste tu primer hábito.', imageUrl: 'assets/images/achievement_1.png', isUnlocked: true),
      Achievement(id: '2', name: '7 Días Seguidos', description: 'Completaste tus hábitos durante 7 días seguidos.', imageUrl: 'assets/images/achievement_2.png'),
    ];
  }

  Future<void> loadAchievements() async {
    _isLoading = true;
    notifyListeners();

    // Simular una llamada a la API (reemplaza esto con tu lógica real)
    await Future.delayed(const Duration(seconds: 1));

    // Aquí iría la lógica para obtener los logros de la API
    // Por ahora, usamos datos de ejemplo
    _achievements = [
      Achievement(id: '1', name: 'Primer Hábito', description: 'Creaste tu primer hábito.', imageUrl: 'assets/images/achievement_1.png', isUnlocked: true),
      Achievement(id: '2', name: '7 Días Seguidos', description: 'Completaste tus hábitos durante 7 días seguidos.', imageUrl: 'assets/images/achievement_2.png'),
    ];

    _isLoading = false;
    notifyListeners();
  }
}