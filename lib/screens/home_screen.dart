import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../widgets/habit_card.dart';
import '../services/habit_service.dart';
import 'package:go_router/go_router.dart';

const Color kPrimaryColor = Color.fromARGB(255, 98, 147, 197);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar los hábitos al iniciar la pantalla
    Provider.of<HabitService>(context, listen: false).loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartHabit'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.go('/settings'); // Navegar a la pantalla de configuración
            },
          ),
        ],
      ),
      body: Consumer<HabitService>(
        builder: (context, habitService, child) {
          if (habitService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (habitService.habits.isEmpty) {
            return const Center(child: Text('No hay hábitos. ¡Crea uno!'));
          } else {
            return ListView.builder(
              itemCount: habitService.habits.length,
              itemBuilder: (context, index) {
                final habit = habitService.habits[index];
                return HabitCard(
                  habit: habit,
                  onTap: () {
                    context.go('/habit/${habit.id}'); // Navegar a los detalles del hábito
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          context.go('/create-habit'); // Navegar a la pantalla de creación de hábito
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}