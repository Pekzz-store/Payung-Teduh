import 'package:flutter/material.dart';

class ThemeService {
  // Menyimpan status tema (System, Light, atau Dark)
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

  // Fungsi untuk mengganti tema saat tombol ditekan
  static void toggleTheme(bool isDark) {
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}