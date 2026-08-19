import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Serif font for headings, titles, logo
  static TextStyle serifHeader({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.bold,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.cinzel(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 1.5,
    );
  }

  // Sans-serif font for buttons, forms, descriptions
  static TextStyle sansBody({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.textSecondary,
    double height = 1.4,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  // Title styles
  static final TextStyle logoText = serifHeader(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.goldPrimary,
  );

  static final TextStyle headline = serifHeader(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle subheadline = sansBody(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static final TextStyle buttonText = GoogleFonts.cinzel(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 24 / 16, // 1.5
    letterSpacing: 0,
    color: Colors.black,
  );

  static final TextStyle labelText = sansBody(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.goldPrimary,
  );
}
