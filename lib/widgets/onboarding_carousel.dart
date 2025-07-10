import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/onboarding_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Importa SmoothPageIndicator

const Color kPrimaryColor = Color.fromARGB(255, 98, 147, 197);

class OnboardingCarousel extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingCarousel({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            OnboardingPage(
              title: "Bienvenido a SmartHabit",
              description: "Crea y sigue tus hábitos de forma efectiva.",
              image: 'assets/images/onboarding_1.svg', // Asegúrate de tener tus imágenes en assets
            ),
            OnboardingPage(
              title: "Recibe Premios",
              description: "Obtén recompensas por alcanzar tus objetivos.",
              image: 'assets/images/onboarding_2.svg',
            ),
            OnboardingPage(
              title: "Comparte tus Logros",
              description: "Inspira a otros compartiendo tus éxitos.",
              image: 'assets/images/onboarding_3.svg',
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          child: Column(
            children: [
              SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                effect: WormEffect( // Correcto: Instancia la clase WormEffect
                  activeDotColor: kPrimaryColor,
                  dotColor: Colors.grey.shade300,
                  dotHeight: 12,
                  dotWidth: 12,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _currentPage < 2
                    ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : widget.onComplete, // Navigate to home
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(_currentPage < 2 ? "Siguiente" : "¡Empezar!"),
              ).animate().scale(duration: 200.ms), // Ejemplo de animación
            ],
          ),
        ),
      ],
    );
  }
}