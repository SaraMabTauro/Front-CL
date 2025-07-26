import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    await authController.checkAuthStatus();

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      if (authController.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
    //if (!mounted) return;

    // La lógica de redirección se basa en el estado del AuthController
    // if (authController.isAuthenticated) {
    //   switch (authController.userRole) {
    //     case UserRole.client:
    //       Navigator.of(context).pushReplacementNamed('/home');
    //       break;
    //     case UserRole.psychologist:
    //       Navigator.of(context).pushReplacementNamed('/psychologist-dashboard');
    //       break;
    //     case UserRole.none:
    //       // Caso improbable, pero seguro
    //       Navigator.of(context).pushReplacementNamed('/login');
    //       break;
    //   }
    // } else {
    //   // Si no está autenticado, va a la pantalla de login principal
    //   Navigator.of(context).pushReplacementNamed('/login');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8C662),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                size: 60,
                color: Color(0xFF595082),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'CloudLove',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Optimizando las relaciones juntos',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
