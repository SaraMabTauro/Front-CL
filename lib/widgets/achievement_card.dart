import 'package:flutter/material.dart';
import '../models/achievement.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({Key? key, required this.achievement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.name,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              achievement.description,
              style: const TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 16.0),
            // Puedes agregar una imagen aquí si lo deseas
          ],
        ),
      ),
    );
  }
}