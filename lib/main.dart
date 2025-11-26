import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';

import 'features/SplashScreen/splash_screen.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- BAGIAN INI YANG SEBELUMNYA HILANG ---
    // Kita wajib pakai ValueListenableBuilder agar aplikasi "mendengar" perubahan
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeNotifier, // <--- Mendengarkan perubahan di sini
      builder: (context, currentMode, child) {
        
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'RainGuard',
          
          // --- PENTING: Sambungkan mode tema ke variabel currentMode ---
          themeMode: currentMode, 
          
          // Konfigurasi Tema Terang
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
          ),

          // Konfigurasi Tema Gelap
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          
          home: const SplashScreen(),
        );
      },
    );
    // --- BATAS AKHIR PERBAIKAN ---
  }
}