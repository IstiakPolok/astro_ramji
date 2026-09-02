import 'package:flutter/material.dart';

class AppColors {
  // Deep Cosmic Backgrounds (Dark Mode)
  static const Color spaceDark = Color(0xFF040209);
  static const Color nebulaDeep = Color(0xFF0F0B1E);
  static const Color cardDark = Color(0xFF141125);
  static const Color borderDark = Color(0xFF242038);

  // Celestial Light Backgrounds (Light Mode)
  static const Color spaceLight = Color(0xFFFCFBF7);
  static const Color nebulaLight = Color(0xFFF7F3EA);
  static const Color cardLight = Color(0xF2FFFFFF);
  static const Color cardLightSolid = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0x30D4A827);

  // Gold / Orange Cosmic Gradients
  static const Color goldLight = Color(0xFFFFDF7A);
  static const Color goldPrimary = Color(0xFFD4A827);
  static const Color goldPrimaryDark = Color(0xFFB8860B);
  static const Color goldOrange = Color(0xFFFF9B17);

  static const Gradient goldGradient = LinearGradient(
    colors: [Color(0xFFFEA703), Color(0xFFFEA703)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const Gradient bgGradient = LinearGradient(
    colors: [Color(0xFF05030A), Color(0xFF0F071D), Color(0xFF180A2A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient bgGradientLight = LinearGradient(
    colors: [Color(0xFFFCFBF7), Color(0xFFFAF5EC), Color(0xFFF5ECDC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient buttonGradient = LinearGradient(
    colors: [Color(0xFFD4A827), Color(0xFFE07820)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color buttonShadow = Color(0x61D4A827);

  // Text Colors (Dark Mode)
  static const Color textPrimary = Color(0xFFF3EFE0);
  static const Color textSecondary = Color(0xFF9E99B3);
  static const Color textMuted = Color(0xFF6C6780);

  // Text Colors (Light Mode)
  static const Color textPrimaryLight = Color(0xFF1B1428);
  static const Color textSecondaryLight = Color(0xFF5A546D);
  static const Color textMutedLight = Color(0xFF8A849F);

  // Status / Accent Colors
  static const Color accentBlue = Color(0xFF66B3FF);
  static const Color accentPurple = Color(0xFFB180FF);
  static const Color accentGreen = Color(0xFF00C853);
  static const Color accentRed = Color(0xFFE53935);

  // Dynamic Theme Helpers
  static Color getBackground(bool isDark) => isDark ? spaceDark : spaceLight;

  static Color getCardBackground(bool isDark) =>
      isDark ? const Color(0x770F0B1E) : const Color(0xEBFFFFFF);

  static Color getCardBorder(bool isDark) =>
      isDark ? goldPrimary.withValues(alpha: 0.25) : const Color(0x40D4A827);

  static Color getTextPrimary(bool isDark) =>
      isDark ? textPrimary : textPrimaryLight;

  static Color getTextSecondary(bool isDark) =>
      isDark ? textSecondary : textSecondaryLight;

  static Color getTextMuted(bool isDark) =>
      isDark ? textMuted : textMutedLight;

  static Color getGold(bool isDark) =>
      isDark ? goldPrimary : goldPrimaryDark;

  static Color getFieldBorder(bool isDark) =>
      isDark ? borderDark : const Color(0x35D4A827);

  static List<Shadow>? getTextShadows(bool isDark) {
    if (isDark) {
      return const [
        Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
      ];
    }
    return null;
  }
}
