import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quiz/firebase_options.dart';
import 'package:quiz/screens/home_screen.dart';
import 'package:quiz/screens/login_screen.dart';
import 'package:quiz/screens/register_screen.dart';
import 'package:quiz/screens/Welcome_screen.dart';
import 'package:quiz/screens/QuizCategoriesScreen.dart';
import 'package:quiz/screens/LeaderboardScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',

      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/categories': (context) => QuizCategoriesScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),




      },

    );
  }
}


