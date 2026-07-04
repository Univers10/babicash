import 'package:flutter/material.dart';

/// Palette BabiCash — extraite du logo officiel.
///   Vert foncé  : "Babi"   #1B6B2F
///   Or/Orange   : "Cash"   #F5A623
///   Brun choco  : portefeuille  #3D1F00
abstract final class AppColors {
  // ── Primaire (vert) ──────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1B6B2F);
  static const Color primaryLight = Color(0xFF2E8B46);
  static const Color primaryDark = Color(0xFF124820);
  static const Color primaryContainer = Color(0xFFD6EFD8);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF0A3316);

  // ── Accent (or/orange) ───────────────────────────────────────────────────
  static const Color accent = Color(0xFFF5A623);
  static const Color accentLight = Color(0xFFFFC35A);
  static const Color accentDark = Color(0xFFBF7E0F);
  static const Color accentContainer = Color(0xFFFFF0D0);
  static const Color onAccent = Color(0xFF1A1A1A);

  // ── Neutre (brun) ────────────────────────────────────────────────────────
  static const Color brown = Color(0xFF3D1F00);

  // ── Surfaces & backgrounds ───────────────────────────────────────────────
  static const Color background = Color(0xFFF7F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0EE);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // ── Sémantiques ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color successContainer = Color(0xFFD6EFD8);
  static const Color warning = Color(0xFFF5A623);
  static const Color warningContainer = Color(0xFFFFF0D0);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color onError = Color(0xFFFFFFFF);

  // ── Textes ───────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF5A5A5A);
  static const Color textTertiary = Color(0xFF9A9A9A);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ── Bordures & dividers ──────────────────────────────────────────────────
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color divider = Color(0xFFEEEEEE);

  // ── Overlays ─────────────────────────────────────────────────────────────
  static const Color scrim = Color(0x80000000);
  static const Color shimmerBase = Color(0xFFEEEEEE);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
