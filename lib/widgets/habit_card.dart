import 'package:flutter/material.dart';
import '../models/habit.dart';

const Color kPrimaryColor = Color.fromARGB(255, 98, 147, 197);

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap; // Función a ejecutar al tocar la tarjeta

  const HabitCard({Key? key, required this.habit, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Asigna la función onTap
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                habit.name,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                habit.description,
                style: const TextStyle(fontSize: 14.0, color: Colors.grey),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso: ${habit.currentProgress}/${habit.target}',
                    style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  //LinearProgressIndicator(value: habit.currentProgress / habit.target),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}