import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../providers/theme_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinnerController;
  Timer? _splashTimer;
  Timer? _navTimer;
  bool _isFadingOut = false;

  @override
  void initState() {
    super.initState();
    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // 3 seconds splash display then smooth transition straight to home
    _splashTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isFadingOut = true;
        });
        _navTimer = Timer(const Duration(milliseconds: 600), () {
          if (mounted) {
            context.go('/home');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _navTimer?.cancel();
    _spinnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final goldColor = AppColors.getGold(isDark);

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: AnimatedOpacity(
        opacity: _isFadingOut ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        child: Stack(
          children: [
            // Celestial Theme Background (respects saved dark/light theme)
            Positioned.fill(
              child: Image.asset(
                isDark ? AppAssets.bgHomeDark : AppAssets.bgLight1,
                fit: BoxFit.cover,
              ),
            ),

            // Theme-adaptive overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            Colors.black.withValues(alpha: 0.20),
                            Colors.black.withValues(alpha: 0.50),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.35),
                          ],
                  ),
                ),
              ),
            ),

            // Main Content: Center Logo & Vedic Tagline
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Golden aura glow container
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: goldColor.withValues(alpha: isDark ? 0.25 : 0.18),
                            blurRadius: 48,
                            spreadRadius: 16,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        AppAssets.logo,
                        width: 250,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'VEDIC ASTROLOGY & HOROSCOPES',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        color: goldColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.2,
                        shadows: AppColors.getTextShadows(isDark) ?? const [
                          Shadow(
                            color: Color(0x33D4A827),
                            blurRadius: 8,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom loading spinner
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: RotationTransition(
                  turns: _spinnerController,
                  child: Image.asset(
                    AppAssets.loading,
                    width: 44,
                    height: 44,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
