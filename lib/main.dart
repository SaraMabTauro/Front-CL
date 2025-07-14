// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'controllers/auth_controller.dart';
// import 'controllers/journaling_controller.dart';
// import 'controllers/task_controller.dart';
// import 'views/splash_screen.dart';
// import 'views/login_screen.dart';
// import './views/home_screens.dart';
// import 'views/individual_log_screen.dart';
// import 'views/interaction_log_screen.dart';
// import 'views/profile_screen.dart';

// void main() {
//   runApp(const CloudLoveApp());
// }

// class CloudLoveApp extends StatelessWidget {
//   const CloudLoveApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthController()),
//         ChangeNotifierProvider(create: (_) => JournalingController()),
//         ChangeNotifierProvider(create: (_) => TaskController()),
//       ],
//       child: MaterialApp(
//         title: 'CloudLove',
//         theme: ThemeData(
//           primarySwatch: Colors.orange,
//           scaffoldBackgroundColor: Colors.white,
//         ),
        
//         // CAMBIAR ESTA LÍNEA PARA PROBAR DIFERENTES PANTALLAS:
        
//         // Para probar SplashScreen:
//         //home: const SplashScreen(),
        
//         // Para probar LoginScreen:
//         // home: const LoginScreen(),
        
//         // Para probar HomeScreen:
//         home: const HomeScreen(),
        
//         // Para probar Individual Log:
//         // home: const IndividualLogScreen(),
        
//         // Para probar Interaction Log:
//         //home: const InteractionLogScreen(),
        
//         // Rutas (mantener para navegación)
//         routes: {
//           '/splash': (context) => const SplashScreen(),
//           '/login': (context) => const LoginScreen(),
//           '/home': (context) => const HomeScreen(),
//           '/profile': (context) => const ProfileScreen(), 
//           '/individual-log': (context) => const IndividualLogScreen(),
//           '/interaction-log': (context) => const InteractionLogScreen(),
//         },
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'controllers/auth_controller.dart';
// import 'controllers/journaling_controller.dart';
// import 'controllers/task_controller.dart';
// import 'controllers/psychologist_controller.dart';
// import 'views/splash_screen.dart';
// import 'views/login_screen.dart';
// import './views/home_screens.dart';
// import 'views/individual_log_screen.dart';
// import 'views/interaction_log_screen.dart';
// import 'views/profile_screen.dart';
// import 'views/psychologist_login_screen.dart';
// import 'views/psychologist_dashboard_screen.dart';
// import 'views/create_couple_screen.dart';


// void main() {
//   runApp(const CloudLoveApp());
// }

// class CloudLoveApp extends StatelessWidget {
//   const CloudLoveApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthController()),
//         ChangeNotifierProvider(create: (_) => JournalingController()),
//         ChangeNotifierProvider(create: (_) => TaskController()),
//         ChangeNotifierProvider(create: (_) => PsychologistController()),
//       ],
//       child: MaterialApp(
//         title: 'CloudLove',
//         theme: ThemeData(
//           primarySwatch: Colors.orange,
//           scaffoldBackgroundColor: Colors.white,
//           fontFamily: 'SF Pro Display',
//         ),
//         initialRoute: '/',
//         routes: {
//           '/': (context) => const SplashScreen(),
//           '/login': (context) => const LoginScreen(),
//           '/home': (context) => const HomeScreen(),
//           '/profile': (context) => const ProfileScreen(), 
//           '/individual-log': (context) => const IndividualLogScreen(),
//           '/interaction-log': (context) => const InteractionLogScreen(),
//           '/psychologist-login': (context) => const PsychologistLoginScreen(),
//           '/psychologist-dashboard': (context) => const PsychologistDashboardScreen(),
//           '/create-couple': (context) => const CreateCoupleScreen(),
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/journaling_controller.dart';
import 'controllers/task_controller.dart';
import 'controllers/psychologist_controller.dart';
import 'views/splash_screen.dart';
import 'views/login_screen.dart';
import 'views/home_screens.dart';
import 'views/individual_log_screen.dart';
import 'views/interaction_log_screen.dart';
import 'views/profile_screen.dart';
import 'views/psychologist_login_screen.dart';
import 'views/psychologist_dashboard_screen.dart';
import 'views/create_couple_screen.dart';
import 'views/couple_detail_screen.dart';
import 'views/create_sesion_screen.dart';
import 'views/register_screen.dart';

void main() {
  runApp(const CloudLoveApp());
}

class CloudLoveApp extends StatelessWidget {
  const CloudLoveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => JournalingController()),
        ChangeNotifierProvider(create: (_) => TaskController()),
        ChangeNotifierProvider(create: (_) => PsychologistController()),
      ],
      child: MaterialApp(
        title: 'CloudLove',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'SF Pro Display',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/register': (context) => const RegisterView(),
          '/individual-log': (context) => const IndividualLogScreen(),
          '/interaction-log': (context) => const InteractionLogScreen(),
          '/psychologist-login': (context) => const PsychologistLoginScreen(),
          '/psychologist-dashboard': (context) => const PsychologistDashboardScreen(),
          '/create-couple': (context) => const CreateCoupleScreen(),
          '/create-session': (context) => const CreateSessionScreen(),

        },
        onGenerateRoute: (settings) {
          if (settings.name == '/couple-detail') {
            final coupleId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => CoupleDetailScreen(coupleId: coupleId),
            );
          }
          return null;
        },
      ),
    );
  }
}
