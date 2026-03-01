import 'package:flutter/material.dart';

/// Palette bleu marine / orange — couleurs éducation nationale
class AppColors {
  AppColors._();

  // Primaires
  static const Color primaryNavy = Color(0xFF1B2A4A);
  static const Color primaryNavyLight = Color(0xFF2C3E6B);
  static const Color primaryNavyDark = Color(0xFF0F1A2E);

  // Accent orange
  static const Color accentOrange = Color(0xFFE67E22);
  static const Color accentOrangeLight = Color(0xFFF39C12);
  static const Color accentOrangeDark = Color(0xFFD35400);

  // Fond & surfaces
  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFEEF1F8);

  // Textes
  static const Color textPrimary = Color(0xFF1B2A4A);
  static const Color textSecondary = Color(0xFF6B7B8D);
  static const Color textLight = Colors.white;

  // Statuts
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Notes & moyennes
  static const Color noteExcellent = Color(0xFF27AE60); // >= 16
  static const Color noteBien = Color(0xFF2ECC71); // >= 14
  static const Color noteAssezBien = Color(0xFFF39C12); // >= 12
  static const Color notePassable = Color(0xFFE67E22); // >= 10
  static const Color noteInsuffisant = Color(0xFFE74C3C); // < 10

  // Rôles
  static const Color roleEleve = Color(0xFF3498DB);
  static const Color roleProfesseur = Color(0xFF27AE60);
  static const Color roleAdmin = Color(0xFFE74C3C);

  static Color getNoteColor(double note) {
    if (note >= 16) return noteExcellent;
    if (note >= 14) return noteBien;
    if (note >= 12) return noteAssezBien;
    if (note >= 10) return notePassable;
    return noteInsuffisant;
  }
}
