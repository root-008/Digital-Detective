import 'package:flutter/material.dart';

class AppColors {
  // Arka Planlar
  static const Color backgroundDark = Color(0xFF0B1021); // Koyu Lacivert/Siyah
  static const Color cardBackground = Color(0xFF151A30); // Kart Rengi
  
  // Ana Renkler (Neon Etkisi)
  static const Color neonBlue = Color(0xFF00F3FF);   // Ana Vurgu
  static const Color neonPurple = Color(0xFFBC13FE); // İkincil Vurgu
  static const Color neonRed = Color(0xFFFF2A6D);    // Hata/Tehlike

  // Metin Renkleri
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF8F9BB3);

  // Gradientler
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonBlue, neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}