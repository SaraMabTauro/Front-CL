import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/achievement_service.dart';
import '../widgets/achievement_card.dart';

const Color kPrimaryColor = Color.fromARGB(255, 98, 147, 197);

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logros'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AchievementService>(
        builder: (context, achievementService, child) {
          if (achievementService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (achievementService.achievements.isEmpty) {
            return const Center(child: Text('No hay logros disponibles.'));
          } else {
            return ListView.builder(
              itemCount: achievementService.achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievementService.achievements[index];
                return AchievementCard(achievement: achievement);
              },
            );
          }
        },
      ),
    );
  }
}