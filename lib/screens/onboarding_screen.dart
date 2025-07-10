import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/onboarding_carousel.dart';
import '../utils/constants.dart';

const Color kBackgroundColor = Color.fromARGB(255, 124, 193, 188);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor, // Un color de fondo suave
      body: OnboardingCarousel(
        onComplete: () async {
          // Marcar que el usuario ya vio el onboarding
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('already_seen', true);

          // Navegar a la pantalla principal
          context.go('/home'); // Usa go_router
        },
      ),
    );
  }
}