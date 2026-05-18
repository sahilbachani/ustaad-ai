import 'package:flutter/material.dart';

/// Ustaad.ai Color Palette
/// High-contrast design optimized for outdoor visibility and low-literacy users.
class AppColors {
  AppColors._();

  // ── Primary: Neon Green = "Go / Active" ──
  static const Color primary = Color(0xFF00FF00);
  static const Color primaryDark = Color(0xFF00CC00);
  static const Color primaryLight = Color(0xFF66FF66);

  // ── Backgrounds ──
  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFF262626);
  static const Color cardBackground = Color(0xFF1E1E1E);

  // ── Text ──
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textOnPrimary = Color(0xFF000000);

  // ── Job Status ──
  static const Color statusPending = Color(0xFFFFC107);
  static const Color statusAccepted = Color(0xFF00FF00);
  static const Color statusArrived = Color(0xFF42A5F5);
  static const Color statusCompleted = Color(0xFF66BB6A);

  // ── Utility ──
  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF00FF00);
  static const Color warning = Color(0xFFFFC107);
  static const Color online = Color(0xFF00FF00);
  static const Color offline = Color(0xFFFF5252);
  static const Color divider = Color(0xFF333333);
}
