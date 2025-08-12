import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';




class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6EB4D1), // Yeni arka plan rengi
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              // Eğlenceli giriş görseli
              Image.asset(
                'assets/images/home_background.jpg',
                height: 180,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 30),

              // Hoş geldiniz yazısı
              Text(
                'Merhaba!',
                style: GoogleFonts.poppins(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // Açıklama
              Text(
                'Hazır mısın? Eğlenceli bir bilgi yolculuğuna çıkıyoruz!',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Animasyonlu giriş butonu
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(seconds: 1),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: SizedBox(
                  width: 250,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8, // Hafif gölge efekti
                    ),
                    child: Text(
                      'Başlayalım!',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Eğlenceli animasyon ikonları
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 40),
                  const SizedBox(width: 12),
                  const Icon(Icons.lightbulb, color: Colors.white, size: 40),
                  const SizedBox(width: 12),
                  const Text('🚀', style: TextStyle(fontSize: 40)), // İkon yerine emoji eklendi
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}