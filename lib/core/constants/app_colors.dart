import 'package:flutter/material.dart';

/// HaramainQu Brand Color Palette
/// Premium Islamic Design: Deep Navy + Gold + Teal
abstract class AppColors {
  // ─── Background Colors ───────────────────────────────────────────────────
  static const Color backgroundPrimary = Color(0xFF0D1B3E);
  static const Color backgroundSecondary = Color(0xFF112040);
  static const Color backgroundCard = Color(0xFF162850);
  static const Color backgroundInput = Color(0xFF1A2D55);
  static const Color backgroundOverlay = Color(0x990D1B3E);

  // ─── Accent / Gold Colors ─────────────────────────────────────────────────
  static const Color accent = Color(0xFFC9A84C);
  static const Color accentLight = Color(0xFFE8C96A);
  static const Color accentDark = Color(0xFFA8873A);
  static const Color accentBorder = Color(0x99C9A84C); // 60% opacity
  static const Color accentDivider = Color(0x33C9A84C); // 20% opacity

  // ─── Accent / Teal Colors (Secondary) ─────────────────────────────────────
  static const Color accentTeal = Color(0xFF0D9F8F);
  static const Color accentTealLight = Color(0xFF14B8A6);
  static const Color accentTealDark = Color(0xFF0A7E71);
  static const Color accentTealBorder = Color(0x990D9F8F);

  // ─── Text Colors ──────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textGold = Color(0xFFC9A84C);
  static const Color textTeal = Color(0xFF14B8A6);
  static const Color textMuted = Color(0xFF6B7FA3);
  static const Color textDark = Color(0xFF0D1B3E);

  // ─── Status Colors ────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0x3310B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0x33F59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0x33EF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0x333B82F6);

  // ─── Ibadah Status Colors ─────────────────────────────────────────────────
  static const Color statusBelum = Color(0xFF6B7FA3);
  static const Color statusSedang = Color(0xFFF59E0B);
  static const Color statusSelesai = Color(0xFF10B981);

  // ─── Divider / Border Colors ──────────────────────────────────────────────
  static const Color divider = Color(0x33C9A84C);
  static const Color border = Color(0x66C9A84C);
  static const Color borderFocused = Color(0xFFC9A84C);

  // ─── Gradient Definitions ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundPrimary, backgroundSecondary],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentLight, accent, accentDark],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentTealLight, accentTeal, accentTealDark],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3460), backgroundCard],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A1628), backgroundPrimary, backgroundSecondary],
  );

  static const LinearGradient trackingGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F2847), Color(0xFF0D1B3E)],
  );
}
