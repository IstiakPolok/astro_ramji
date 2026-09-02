import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../providers/theme_provider.dart';
import '../main_navigation_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _videoController =
        VideoPlayerController.asset(AppAssets.videoHomeBg)
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                _isVideoInitialized = true;
              });
              _videoController?.setLooping(true);
              _videoController?.setVolume(0.0); // Muted background video
              _videoController?.setPlaybackSpeed(0.50);
              _videoController?.play();
            }
          });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: SafeArea(
        child: Stack(
          children: [
            // Celestial Astrological Background
            // In Light Mode: LIGHT.png
            // In Dark Mode: Video or home_bg.png fallback
            Positioned.fill(
              child: isDark
                  ? (_isVideoInitialized && _videoController != null
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoController!.value.size.width,
                            height: _videoController!.value.size.height,
                            child: VideoPlayer(_videoController!),
                          ),
                        )
                      : Image.asset(
                          AppAssets.bgHomeDark,
                          fit: BoxFit.cover,
                        ))
                  : Image.asset(
                      AppAssets.bgLight1,
                      fit: BoxFit.cover,
                    ),
            ),
            // Overlay for readability
            Positioned.fill(
              child: Container(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.20)
                    : Colors.white.withValues(alpha: 0.25),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Section: Profile Info & Theme Switcher
                            _buildProfileHeader(isDark, themeProvider),
                            const SizedBox(height: 20),

                            // Quote section
                            _buildQuoteSection(isDark),
                            const SizedBox(height: 20),

                            // Today's Forecast Button
                            _buildForecastButton(),
                            const SizedBox(height: 24),

                            // Today's Panchang Card
                            _buildPanchangCard(isDark),
                            const SizedBox(height: 24),

                            // Quick Actions Header
                            _buildSectionHeader('QUICK ACTIONS', isDark),
                            const SizedBox(height: 16),

                            // Quick Actions Grid (Row of 2)
                            _buildQuickActionsRow1(),
                            const SizedBox(height: 24),

                            // Jupiter Mahadasha Card
                            _buildMahadashaCard(isDark),
                            const SizedBox(height: 24),

                            // Quick Actions Header 2
                            _buildSectionHeader('QUICK ACTIONS', isDark),
                            const SizedBox(height: 16),

                            // Quick Actions Row 2
                            _buildQuickActionsRow2(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Profile Header & Theme Toggle ---
  Widget _buildProfileHeader(bool isDark, ThemeProvider themeProvider) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AARAV SHARMA',
              style: GoogleFonts.cinzel(
                color: goldColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                shadows: textShadows,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Monday, 11 August 2026',
              style: GoogleFonts.roboto(
                color: isDark ? const Color(0xFFFF4D4D) : const Color(0xFFD32F2F),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                shadows: textShadows,
              ),
            ),
          ],
        ),

        // Quick Theme Toggle Button
        GestureDetector(
          onTap: () {
            themeProvider.toggleTheme();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: goldColor.withValues(alpha: 0.4),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : goldColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? AppColors.goldLight : AppColors.goldPrimaryDark,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  isDark ? 'LIGHT' : 'DARK',
                  style: GoogleFonts.cinzel(
                    color: goldColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Quote Section ---
  Widget _buildQuoteSection(bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '“',
          style: GoogleFonts.cinzel(
            color: goldColor,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 0.8,
            shadows: textShadows,
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -12),
          child: Text(
            'The cosmos holds the map,\nyour journey writes the story.',
            style: GoogleFonts.roboto(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.9)
                  : AppColors.textPrimaryLight.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: isDark ? FontWeight.normal : FontWeight.w500,
              height: 1.4,
              shadows: textShadows,
            ),
          ),
        ),
      ],
    );
  }

  // --- Forecast Button ---
  Widget _buildForecastButton() {
    return Container(
      width: 170,
      height: 40,
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: AppColors.buttonShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          "Today's Forecast",
          style: GoogleFonts.cinzel(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- Today's Panchang ---
  Widget _buildPanchangCard(bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x770F0B1E) : const Color(0xE8FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: goldColor.withValues(alpha: isDark ? 0.25 : 0.4),
          width: 1.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TODAY'S PANCHANG",
                style: GoogleFonts.cinzel(
                  color: goldColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: textSecondary,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '11 Aug 2026',
                    style: GoogleFonts.roboto(
                      color: textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Panchang Details Grid (2 - 2 - 2 - 1 layout)
          Row(
            children: [
              Expanded(
                child: _buildPanchangItem(
                  'Tithi',
                  'Saptami (7th)',
                  Icons.nightlight_round,
                  Colors.redAccent,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPanchangItem(
                  'Nakshatra',
                  'Ashlesha',
                  Icons.star_border_rounded,
                  isDark ? Colors.greenAccent : const Color(0xFF2E7D32),
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPanchangItem(
                  'Yoga',
                  'Siddha',
                  Icons.spa_outlined,
                  isDark ? Colors.purpleAccent : const Color(0xFF7B1FA2),
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPanchangItem(
                  'Karana',
                  '07:12pm',
                  Icons.circle_outlined,
                  isDark ? Colors.orangeAccent : const Color(0xFFE65100),
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPanchangItem(
                  'Sunrise',
                  '07:12pm',
                  Icons.wb_sunny_outlined,
                  isDark ? Colors.yellowAccent : const Color(0xFFF57F17),
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPanchangItem(
                  'Sunset',
                  '07:12pm',
                  Icons.wb_twilight_outlined,
                  isDark ? Colors.blueAccent : const Color(0xFF1976D2),
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildPanchangItem(
                  'Rahu kaal',
                  '07:12pm',
                  Icons.timelapse_outlined,
                  isDark ? Colors.pinkAccent : const Color(0xFFC2185B),
                  isDark,
                ),
              ),
              const Expanded(
                flex: 1,
                child: SizedBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPanchangItem(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    bool isDark,
  ) {
    final goldColor = AppColors.getGold(isDark);
    final textColor = AppColors.getTextPrimary(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C091A) : const Color(0xFFFAF7F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0x30D4A827),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Circular icon container
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.15 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cinzel(
                    color: goldColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.roboto(
                    color: textColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Section Header ---
  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.cinzel(
        color: AppColors.getGold(isDark),
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }

  // --- Quick Actions Row 1 (Generate Kundali & Kundali matching) ---
  Widget _buildQuickActionsRow1() {
    return Row(
      children: [
        // Generate Kundali (Green)
        Expanded(
          child: GestureDetector(
            onTap: () {
              context
                  .findAncestorStateOfType<MainNavigationScreenState>()
                  ?.setIndex(1);
            },
            child: Image.asset(
              AppAssets.kundaliButton,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Kundali Matching (Pink)
        Expanded(
          child: GestureDetector(
            onTap: () {
              context
                  .findAncestorStateOfType<MainNavigationScreenState>()
                  ?.setIndex(3);
            },
            child: Image.asset(
              AppAssets.kundaliMatchingButton,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  // --- Jupiter Mahadasha Card ---
  Widget _buildMahadashaCard(bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textColor = AppColors.getTextPrimary(isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x770F0B1E) : const Color(0xE8FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: goldColor.withValues(alpha: isDark ? 0.2 : 0.4),
          width: 1.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          // Jupiter Planet Image
          Image.asset(
            AppAssets.jupiter,
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JUPITER MAHADASHA',
                  style: GoogleFonts.cinzel(
                    color: goldColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2023–2039 · Currently active',
                  style: GoogleFonts.roboto(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: isDark ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // Progress Bar
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.borderDark : const Color(0x25D4A827),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.5, // 50% progress
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: AppColors.buttonGradient,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Compass Icon
          Image.asset(
            AppAssets.rashiChakra,
            width: 36,
            height: 36,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  // --- Quick Actions Row 2 (Mangal Dosha & Sade Sati) ---
  Widget _buildQuickActionsRow2() {
    return Row(
      children: [
        // Mangal Dosha
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Image.asset(
              AppAssets.mangalDosha,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Sade Sati
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Image.asset(
              AppAssets.sadeSati,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
