import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Kullanıcının ismi yoksa e-posta adresinden al ya da varsayılan isim
    final userName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : (user?.email?.split('@')[0] ?? 'Quiz Kahramanı');

    void startQuiz() {
      Navigator.pushNamed(context, '/categories');
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text("Quiz Paneli"),
        backgroundColor: const Color(0xFF5477C4),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Hoş geldin, $userName!",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF274374),
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                "Bilgini test etmeye hazır mısın?\nHaydi bakalım, başarı seninle olsun! 🚀",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF3A559F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7DA3F5),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: Colors.blueAccent.shade100,
                ),
                icon: const Icon(Icons.play_arrow, size: 24, color: Colors.white),
                label: const Text(
                  "Haydi Yarışmaya Başla!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
