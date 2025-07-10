import 'package:flutter/material.dart';

class Habit {
  String id;
  String name;
  String description;
  String frequency;
  int target;
  int currentProgress;
  String unit;
  TimeOfDay? reminderTime;
  bool isCompleted;


  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.frequency,
    required this.target,
    required this.currentProgress,
    required this.unit,
    this.reminderTime,
    this.isCompleted = false,
  });

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    String? frequency,
    int? target,
    int? currentProgress,
    String? unit,
    TimeOfDay? reminderTime,
    bool? isCompleted,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      target: target ?? this.target,
      currentProgress: currentProgress ?? this.currentProgress,
      unit: unit ?? this.unit,
      reminderTime: reminderTime ?? this.reminderTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
// Método para convertir el objeto a un Map (para guardar en la base de datos)
  Map<String, dynamic> toMap() {
    return{
      'id': id,
      'name': name,
      'description': description,
      'frequency': frequency,
      'target': target,
      'currentProgress': currentProgress,
      'unit': unit,
      'reminderTime': reminderTime != null ? '${reminderTime!.hour}:${reminderTime!.minute}' : null,
      'isCompleted': isCompleted ? 1 : 0, // Convertir booleano a entero
    };
  }
  // Método para crear un objeto Habit desde un Map (para leer desde la base de datos)
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      frequency: map['frequency'] as String,
      target: map['target'] as int,
      currentProgress: map['currentProgress'] as int,
      unit: map['unit'] as String,
      reminderTime: map['reminderTime'] != null
          ? TimeOfDay(
              hour: int.parse(map['reminderTime'].split(':')[0]),
              minute: int.parse(map['reminderTime'].split(':')[1]),
            )
          : null,
      isCompleted: (map['isCompleted'] as int) == 1, // Convertir entero a booleano
    );
  }

  // Función auxiliar para convertir un String a TimeOfDay
  static TimeOfDay? stringToTimeOfDay(String time) {
    final parts = time.split(':');
    if (parts.length == 2) {
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    return null;
  }
}