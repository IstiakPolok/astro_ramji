import 'package:flutter/material.dart';

class AppColors {
  // Deep Cosmic Backgrounds
  static const Color spaceDark = Color(0xFF040209);
  static const Color nebulaDeep = Color(0xFF0F0B1E);
  static const Color cardDark = Color(0xFF141125);
  static const Color borderDark = Color(0xFF242038);

  // Gold / Orange Cosmic Gradients
  static const Color goldLight = Color(0xFFFFDF7A);
  static const Color goldPrimary = Color(0xFFD4A827);
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

  static const Gradient buttonGradient = LinearGradient(
    colors: [Color(0xFFD4A827), Color(0xFFE07820)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color buttonShadow = Color(0x61D4A827);

  // Text Colors
  static const Color textPrimary = Color(0xFFF3EFE0);
  static const Color textSecondary = Color(0xFF9E99B3);
  static const Color textMuted = Color(0xFF6C6780);

  // Status/Other
  static const Color accentBlue = Color(0xFF66B3FF);
  static const Color accentPurple = Color(0xFFB180FF);
}
