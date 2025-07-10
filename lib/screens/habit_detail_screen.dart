import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import 'package:go_router/go_router.dart';

const Color kPrimaryColor = Color.fromARGB(255, 98, 147, 197);


class HabitDetailScreen extends StatelessWidget {
  final String habitId;

  const HabitDetailScreen({Key? key, required this.habitId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Acceder al HabitService
    final habitService = Provider.of<HabitService>(context);

    // Obtener el hábito por ID
    final habit = habitService.getHabitById(habitId);

    // Manejar el caso en que el hábito no se encuentra
    if (habit == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalles del Hábito'),
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Hábito no encontrado.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habit.description,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            Text('Frecuencia: ${habit.frequency}', style: const TextStyle(fontSize: 16.0)),
            const SizedBox(height: 16.0),
            Text('Objetivo: ${habit.target} ${habit.unit}', style: const TextStyle(fontSize: 16.0)),
            const SizedBox(height: 16.0),
            Text('Progreso: ${habit.currentProgress} / ${habit.target}',
                style: const TextStyle(fontSize: 16.0)),
            const SizedBox(height: 24.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // TODO: Implementar lógica para marcar el hábito como completado hoy
                // Actualizar el progreso actual del hábito
                // Notificar a los usuarios (si se configuraron recordatorios)
                //context.pop();
              },
              child: const Text('Completado Hoy'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Eliminar el hábito
                habitService.deleteHabit(habit.id);
                context.pop(); // Regresar a la pantalla anterior
              },
              child: const Text('Eliminar Hábito'),
            ),
          ],
        ),
      ),
    );
  }
}