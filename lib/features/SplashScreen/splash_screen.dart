import 'package:flutter/material.dart';
import 'dart:async';

// Import halaman AuthGate
import '../auth/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Tambahkan 'with SingleTickerProviderStateMixin' untuk animasi
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Variabel untuk mengontrol animasi
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Konfigurasi Animasi (Durasi animasi 2 detik)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Efek Membal (Elastic) untuk Logo
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    // Efek Muncul Perlahan (Fade In) untuk Teks
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Mulai Animasi
    _controller.forward();

    // 2. Timer Navigasi (Dibuat lebih lama: 5 Detik)
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller
        .dispose(); // Hapus controller animasi saat pindah halaman agar hemat memori
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // BACKGROUND: Gradasi warna agar lebih cantik
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1565C0), // Biru agak gelap
              Color(0xFF42A5F5), // Biru terang
            ],
          ),
        ),
        child: Stack(
          children: [
            // KONTEN TENGAH (Logo & Teks)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animasi Logo (Scale)
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(
                          0.15,
                        ), // Lingkaran transparan
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.beach_access,
                        size: 100, // Ukuran lebih besar
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Animasi Teks (Fade)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: const [
                        Text(
                          "RainGuard",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 3,
                            fontFamily:
                                'Roboto', // Default font flutter yang bagus
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black26,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Sedia Payung Sebelum Hujan",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Loading Indicator Custom
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ],
              ),
            ),

            // FOOTER (Versi Aplikasi di Bawah)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Versi 1.0.0",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
