import 'package:flutter/material.dart';

/// Application Color Constants - Calming Blue-Green Theme for Focus & Wellbeing
class AppColors {
  AppColors._();

  // Primary Colors - Calm Navy Blue with Teal accents
  static const Color primary = Color(
    0xFF0D1B2A,
  ); // Deep navy (dark background base)
  static const Color primaryVariant = Color(
    0xFF1B263B,
  ); // Slightly lighter for cards
  static const Color primaryLight = Color(
    0xFF4A90E2,
  ); // Calm blue for accents/buttons

  // Secondary / Accent - Soft Teal/Green for positive actions (focus, success)
  static const Color secondary = Color(
    0xFF50C878,
  ); // Mint green (calming & refreshing)
  static const Color secondaryLight = Color(0xFF7ED9A0);
  static const Color accent = Color(0xFF78D5D7); // Soft teal for highlights

  // Background Colors
  static const Color backgroundLight = Color(
    0xFFF5F9FF,
  ); // Very soft blue-white
  static const Color backgroundDark = Color(0xFF0D1B2A); // Deep calm navy
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1B263B);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF2D3436);
  static const Color textSecondaryLight = Color(0xFF636E72);
  static const Color textPrimaryDark = Color(
    0xFFE0E7FF,
  ); // Off-white for dark mode
  static const Color textSecondaryDark = Color(0xFFB0BEC5);
  static const Color textOnPrimary = Colors.white;

  // Status Colors
  static const Color success = Color(0xFF50C878); // Mint green
  static const Color warning = Color(0xFFFFB74D); // Soft orange
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF74B9FF);

  // Border & Divider
  static const Color borderLight = Color(0xFFE0E7FF);
  static const Color borderDark = Color(0xFF334155);
  static const Color dividerLight = Color(0xFFECF0F1);
  static const Color dividerDark = Color(0xFF415A77);

  // Gradients - Calming & Soft
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF293A6B),
      Color.fromARGB(255, 0, 0, 0),
    ], // Blue to Green calm transition
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF78D5D7), Color(0xFF50C878)], // Teal to Mint
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF50C878), Color(0xFF7ED9A0)],
  );
}
