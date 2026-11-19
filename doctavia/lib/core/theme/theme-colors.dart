import 'package:flutter/material.dart';

/// Design tokens for the Doctavia app.
/// Focused exclusively on the vibrant purple aesthetic with high-contrast light mode.
class AppColors {
  AppColors._();

  // --- Core Brand Colors ----------------------------------------
  static const Color primary          = Color(0xFF7C4DFF); // Vibrant Purple
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color secondary        = Color(0xFFF3F0FF); // Soft Lavender
  static const Color secondaryForeground = Color(0xFF7C4DFF);
  
  // --- Background & Surface -------------------------------------
  static const Color background       = Color(0xFFFBFBFE);
  static const Color foreground       = Color(0xFF0F172A); // Deep Slate for readability
  static const Color card             = Color(0xFFFFFFFF);
  static const Color cardForeground   = Color(0xFF0F172A);
  
  // --- Component Specifics --------------------------------------
  static const Color muted            = Color(0xFFF1F5F9);
  static const Color mutedForeground  = Color(0xFF64748B);
  static const Color accent           = Color(0xFFEEF2FF);
  static const Color accentForeground = Color(0xFF4F46E5);
  static const Color destructive      = Color(0xFFEF4444);
  static const Color border           = Color(0xFFE2E8F0);
  static const Color input            = Color(0xFFE2E8F0);
  static const Color ring             = Color(0xFF7C4DFF);

  // --- Status Colors --------------------------------------------
  static const Color success          = Color(0xFF10B981);
  static const Color warning          = Color(0xFFF59E0B);
  static const Color info             = Color(0xFF2563EB);

  // --- Chart Colors ---------------------------------------------
  static const Color chart1 = Color(0xFF7C4DFF);
  static const Color chart2 = Color(0xFF9279F8);
  static const Color chart3 = Color(0xFFB09FFF);
  static const Color chart4 = Color(0xFFD1C8FF);
  static const Color chart5 = Color(0xFFE9E5FF);

  // --- Sidebar / Navigation ------------------------------------
  static const Color sidebar           = Color(0xFFFFFFFF);
  static const Color sidebarForeground = Color(0xFF0F172A);
  static const Color sidebarPrimary    = Color(0xFF7C4DFF);
  static const Color sidebarPrimaryFg  = Color(0xFFFFFFFF);
  static const Color sidebarAccentFg   = Color(0xFF7C4DFF);
  static const Color sidebarBorder     = Color(0xFFE2E8F0);

  // --- Shadow Tokens --------------------------------------------
  static const Color shadow            = Color(0x0A0F172A); // 4% opacity deep slate
  static const Color shadowIntense     = Color(0x140F172A); // 8% opacity deep slate
}
