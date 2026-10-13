import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/astrology_api_provider.dart';
import '../../widgets/theme_picker_sheet.dart';
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
    // Video Background for Dark Mode
    _videoController = VideoPlayerController.asset(AppAssets.videoHomeBg)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          _videoController?.setLooping(true);
          _videoController?.setVolume(0.0);
          _videoController?.setPlaybackSpeed(0.50);
          _videoController?.play();
        }
      });

    // Fetch Today's Panchang & Astrological forecast via OpenAPI v1
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AstrologyApiProvider>(context, listen: false)
            .fetchTodayPanchang();
      }
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _showLanguagePicker(BuildContext context, bool isDark) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final goldColor = AppColors.getGold(isDark);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.spaceDark : AppColors.spaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: goldColor, width: 1.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr('select_language'),
                style: GoogleFonts.cinzel(
                  color: goldColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: LanguageProvider.supportedLanguages.length,
                  itemBuilder: (context, index) {
                    final lang = LanguageProvider.supportedLanguages[index];
                    final isSelected = lang.code == languageProvider.currentLanguageCode;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? goldColor.withValues(alpha: 0.2)
                              : (isDark ? Colors.white12 : const Color(0x20D4A827)),
                          border: Border.all(
                            color: isSelected ? goldColor : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            lang.scriptSymbol,
                            style: GoogleFonts.roboto(
                              color: isSelected ? goldColor : (isDark ? Colors.white : AppColors.textPrimaryLight),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        lang.nativeName,
                        style: GoogleFonts.roboto(
                          color: isSelected ? goldColor : (isDark ? Colors.white : AppColors.textPrimaryLight),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        lang.englishName,
                        style: GoogleFonts.roboto(
                          color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                          fontSize: 12,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: goldColor)
                          : null,
                      onTap: () {
                        languageProvider.setLanguageCode(lang.code);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: SafeArea(
        child: Stack(
          children: [
            // Celestial Background
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
            // Translucent Cover
            Positioned.fill(
              child: Container(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.20)
                    : Colors.white.withValues(alpha: 0.15),
              ),
            ),

            // Scrollable Body Content
            SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Section: Profile Info, Language & Theme Switcher
                          _buildProfileHeader(isDark, themeProvider, languageProvider),
                          const SizedBox(height: 20),

                          // Quote section
                          _buildQuoteSection(isDark),
                          const SizedBox(height: 20),

                          // Today's Forecast Button
                          _buildForecastButton(isDark),
                          const SizedBox(height: 24),

                          // Today's Panchang Card
                          _buildPanchangCard(isDark),
                          const SizedBox(height: 24),

                          // Quick Actions Header
                          _buildSectionHeader(context.tr('quick_actions'), isDark),
                          const SizedBox(height: 16),

                          // Quick Actions Grid (Row of 2)
                          _buildQuickActionsRow1(isDark),
                          const SizedBox(height: 24),

                          // Jupiter Mahadasha Card
                          _buildMahadashaCard(isDark),
                          const SizedBox(height: 24),

                          // Quick Actions Header 2
                          _buildSectionHeader(context.tr('quick_actions'), isDark),
                          const SizedBox(height: 16),

                          // Quick Actions Row 2
                          _buildQuickActionsRow2(isDark),
                          const SizedBox(height: 20),
                        ],
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

  // --- Profile Header, Language Picker & Theme Toggle ---
  Widget _buildProfileHeader(bool isDark, ThemeProvider themeProvider, LanguageProvider languageProvider) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Consumer<AstrologyApiProvider>(
          builder: (context, api, _) {
            final userName = api.activeProfile?.name;
            final displayName = (userName != null && userName.trim().isNotEmpty)
                ? userName.trim().toUpperCase()
                : context.tr('greeting_user');

            final now = DateTime.now();
            const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
            const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
            final dynamicDate = '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.cinzel(
                    color: goldColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    shadows: textShadows,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dynamicDate,
                  style: GoogleFonts.roboto(
                    color: isDark ? const Color(0xFFFF4D4D) : const Color(0xFFD32F2F),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    shadows: textShadows,
                  ),
                ),
              ],
            );
          },
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick Language Selector Button
            GestureDetector(
              onTap: () => _showLanguagePicker(context, isDark),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                          : goldColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.translate_rounded,
                      color: isDark ? AppColors.goldLight : AppColors.goldPrimaryDark,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      languageProvider.currentLanguageCode.toUpperCase(),
                      style: GoogleFonts.cinzel(
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Quick Theme Selector Button
            GestureDetector(
              onTap: () => showThemePickerSheet(context, isDark),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                          : goldColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      themeProvider.themeMode == ThemeMode.system
                          ? Icons.brightness_auto_rounded
                          : (isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                      color: isDark ? AppColors.goldLight : AppColors.goldPrimaryDark,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      themeProvider.themeMode == ThemeMode.system
                          ? 'AUTO'
                          : (isDark ? 'DARK' : 'LIGHT'),
                      style: GoogleFonts.cinzel(
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Quote Card ---
  Widget _buildQuoteSection(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        context.tr('home_quote'),
        style: GoogleFonts.roboto(
          color: isDark ? Colors.white : AppColors.textPrimaryLight,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
          height: 1.4,
          shadows: AppColors.getTextShadows(isDark),
        ),
      ),
    );
  }

  // --- Today's Forecast Button ---
  Widget _buildForecastButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        final navState = context.findAncestorStateOfType<MainNavigationScreenState>();
        navState?.setIndex(2);
      },
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: AppColors.buttonShadow,
              blurRadius: 15,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "${context.tr('todays_forecast')} ➔",
            style: GoogleFonts.cinzel(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  // --- Panchang Card ---
  Widget _buildPanchangCard(bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final cardBg = isDark
        ? const Color(0xFF0C071D).withValues(alpha: 0.85)
        : const Color(0xF5FFFFFF);

    final borderColor = isDark
        ? AppColors.goldPrimary.withValues(alpha: 0.25)
        : const Color(0x40D4A827);

    final apiProvider = Provider.of<AstrologyApiProvider>(context);
    final panchang = apiProvider.todayPanchang;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('todays_panchang'),
                style: GoogleFonts.cinzel(
                  color: goldColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              if (apiProvider.isLoadingToday)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.goldPrimary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // 2x2 Grid: Tithi, Nakshatra, Yoga, Karana
          Row(
            children: [
              Expanded(
                child: _buildPanchangItem(
                  context.tr('tithi'),
                  panchang?.tithi ?? 'Shukla Ashtami',
                  const Color(0xFFCE7C2E),
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPanchangItem(
                  context.tr('nakshatra'),
                  panchang?.nakshatra ?? 'Rohini',
                  const Color(0xFF8B5CF6),
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
                  context.tr('yoga'),
                  panchang?.yoga ?? 'Indra',
                  const Color(0xFF10B981),
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPanchangItem(
                  context.tr('karana'),
                  panchang?.karana ?? 'Bava',
                  const Color(0xFFEC4899),
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Divider
          Divider(
            color: isDark ? AppColors.borderDark : const Color(0x20D4A827),
            height: 1,
            thickness: 1,
          ),
          const SizedBox(height: 16),

          // Bottom Bar: Sunrise, Sunset, Rahu Kaal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBottomInfoItem(
                Icons.wb_sunny_outlined,
                context.tr('sunrise'),
                panchang?.sunrise ?? '06:12 AM',
                isDark,
              ),
              _buildBottomInfoItem(
                Icons.nightlight_outlined,
                context.tr('sunset'),
                panchang?.sunset ?? '06:45 PM',
                isDark,
              ),
              _buildBottomInfoItem(
                Icons.schedule_outlined,
                context.tr('rahu_kaal'),
                panchang?.rahuKaal ?? '04:30 - 06:00',
                isDark,
                valueColor: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPanchangItem(String label, String value, Color badgeColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFFAF7F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0x25D4A827),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.cinzel(
              color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              shadows: AppColors.getTextShadows(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.roboto(
              color: badgeColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfoItem(
    IconData icon,
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.getGold(isDark),
          size: 16,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.roboto(
                color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                fontSize: 10,
                shadows: AppColors.getTextShadows(isDark),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.roboto(
                color: valueColor ?? (isDark ? Colors.white : AppColors.textPrimaryLight),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                shadows: AppColors.getTextShadows(isDark),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Section Headers ---
  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.cinzel(
        color: AppColors.getGold(isDark),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        shadows: AppColors.getTextShadows(isDark),
      ),
    );
  }

  // --- Quick Actions Grid 1 ---
  Widget _buildQuickActionsRow1(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            title: context.tr('generate_kundali_btn'),
            imageAsset: AppAssets.kundaliButton,
            isDark: isDark,
            onTap: () {
              final navState = context.findAncestorStateOfType<MainNavigationScreenState>();
              navState?.setIndex(1); // Kundali Tab
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            title: context.tr('kundali_matching_btn'),
            imageAsset: AppAssets.kundaliMatchingButton,
            isDark: isDark,
            onTap: () {
              final navState = context.findAncestorStateOfType<MainNavigationScreenState>();
              navState?.setIndex(3); // Matching Tab
            },
          ),
        ),
      ],
    );
  }

  // --- Quick Actions Grid 2 ---
  Widget _buildQuickActionsRow2(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            title: context.tr('mangal_dosha_btn'),
            imageAsset: AppAssets.noMangalDosha,
            isDark: isDark,
            onTap: () {
              final navState = context.findAncestorStateOfType<MainNavigationScreenState>();
              navState?.setIndex(1); // Go to Kundali
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            title: context.tr('sade_sati_btn'),
            imageAsset: AppAssets.sadeSati,
            isDark: isDark,
            onTap: () {
              final navState = context.findAncestorStateOfType<MainNavigationScreenState>();
              navState?.setIndex(1); // Go to Kundali
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String imageAsset,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final goldColor = AppColors.getGold(isDark);
    final cardBg = isDark
        ? const Color(0xFF140F27).withValues(alpha: 0.7)
        : const Color(0xF5FFFFFF);

    final borderColor = isDark
        ? AppColors.goldPrimary.withValues(alpha: 0.25)
        : const Color(0x35D4A827);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 1.2,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                imageAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.auto_awesome,
                    color: goldColor,
                    size: 40,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.cinzel(
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                shadows: AppColors.getTextShadows(isDark),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // --- Jupiter Mahadasha Card ---
  Widget _buildMahadashaCard(bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final cardBg = isDark
        ? const Color(0xFF0C071D).withValues(alpha: 0.85)
        : const Color(0xF5FFFFFF);

    final borderColor = isDark
        ? AppColors.goldPrimary.withValues(alpha: 0.25)
        : const Color(0x40D4A827);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Image.asset(
                  AppAssets.jupitar,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.circle,
                    color: goldColor,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('jupiter_mahadasha'),
                      style: GoogleFonts.cinzel(
                        color: goldColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('mahadasha_sub'),
                      style: GoogleFonts.roboto(
                        color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                        fontSize: 11,
                        shadows: AppColors.getTextShadows(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 6,
              color: isDark ? Colors.white12 : const Color(0x25D4A827),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.25, // 2023 to 2026 = 3/16th ≈ 25%
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.buttonGradient,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
