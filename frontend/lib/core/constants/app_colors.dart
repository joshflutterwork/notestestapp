import 'package:flutter/material.dart';

class AppColors {
  // Lighter Background Gradients (Lebih ke putih/abu terang)
  static const Color bgDark = Color(0xFFF8FAFC);
  static const Color bgGradientStart = Color(0xFFF1F5F9); // Slate 100
  static const Color bgGradientEnd = Color(0xFFE2E8F0); // Slate 200

  // Accent Colors (Tetap pakai warna asli dari aset)
  static const Color accentOrange = Color(0xFFB56D3D);
  static const Color accentGold = Color(0xFFE9C46A);

  // Glassmorphism untuk background terang
  static const Color glassWhite = Color(0xB3FFFFFF); // White 70% Opacity
  static const Color glassBorder = Color(0xFFFFFFFF); // Border putih solid

  // Typography & Icons (Digelapkan biar kontras maksimal)
  static const Color textPrimary = Color(
    0xFF0F172A,
  ); // Slate 900 (Hampir hitam)
  static const Color textSecondary = Color(
    0xFF475569,
  ); // Slate 600 (Abu-abu kebiruan gelap)
}
