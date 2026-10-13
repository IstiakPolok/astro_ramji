import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../providers/astrology_api_provider.dart';
import '../../../data/models/horoscope_model.dart';

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  // Selected sign index
  int _selectedSignIndex = 0;

  // Selected timeframe tab (0 = Today/Daily, 1 = Monthly, 2 = Yearly)
  int _selectedTimeframe = 0;

  String get _currentPeriodType {
    switch (_selectedTimeframe) {
      case 0:
        return 'daily';
      case 1:
        return 'monthly';
      case 2:
        return 'yearly';
      default:
        return 'daily';
    }
  }

  @override
  void initState() {
    super.initState();
    _initVideo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _initVideo() {
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
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<AstrologyApiProvider>(context, listen: false);
    await provider.fetchHoroscopeSigns();
    if (!mounted) return;
    final signs = provider.zodiacSigns.isNotEmpty
        ? provider.zodiacSigns
        : ZodiacSignModel.defaultSigns;
    final currentSign = signs[_selectedSignIndex.clamp(0, signs.length - 1)];
    provider.fetchHoroscope(
      zodiac: currentSign.slug,
      periodType: _currentPeriodType,
    );
  }

  void _loadHoroscope(String slug, {bool forceRefresh = false}) {
    final provider = Provider.of<AstrologyApiProvider>(context, listen: false);
    provider.fetchHoroscope(
      zodiac: slug,
      periodType: _currentPeriodType,
      forceRefresh: forceRefresh,
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final apiProvider = Provider.of<AstrologyApiProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final signs = apiProvider.zodiacSigns.isNotEmpty
        ? apiProvider.zodiacSigns
        : ZodiacSignModel.defaultSigns;
    final safeIndex = _selectedSignIndex.clamp(0, signs.length - 1);
    final activeZodiac = signs[safeIndex];
    final activeHoroscope = apiProvider.currentHoroscope;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Video or Image
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
                      AppAssets.bgLight3,
                      fit: BoxFit.cover,
                    ),
            ),
            // Translucent Cover
            Positioned.fill(
              child: Container(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.20)
                    : Colors.white.withValues(alpha: 0.20),
              ),
            ),

            // Scrollable Content with Pull-To-Refresh
            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                color: AppColors.goldPrimary,
                backgroundColor: isDark ? const Color(0xFF1E1E28) : Colors.white,
                onRefresh: () async {
                  await Future.wait([
                    apiProvider.fetchHoroscopeSigns(),
                    apiProvider.fetchHoroscope(
                      zodiac: activeZodiac.slug,
                      periodType: _currentPeriodType,
                      forceRefresh: true,
                    ),
                  ]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // Header Brand
                      Center(child: _buildHeaderTitle(isDark)),
                      const SizedBox(height: 24),

                      // Zodiac Sign Selector
                      _buildHorizontalZodiacSelector(signs, safeIndex, isDark),
                      const SizedBox(height: 24),

                      // Timeframe Tabs (Today/Daily, Monthly, Yearly)
                      _buildTimeframeTabBar(isDark, activeZodiac),
                      const SizedBox(height: 24),

                      // Main Dynamic Horoscope Card
                      _buildHoroscopeCard(
                        zodiac: activeZodiac,
                        horoscope: activeHoroscope,
                        isLoading: apiProvider.isLoadingHoroscope,
                        error: apiProvider.horoscopeError,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderTitle(bool isDark) {
    final textShadows = AppColors.getTextShadows(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final subtitleColor = isDark ? Colors.white70 : AppColors.textSecondaryLight;

    return Column(
      children: [
        Text(
          context.tr('daily_horoscope'),
          style: GoogleFonts.cinzel(
            color: textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            shadows: textShadows,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr('horoscope_sub'),
          style: GoogleFonts.roboto(
            color: subtitleColor,
            fontSize: 11,
            shadows: textShadows,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHorizontalZodiacSelector(
    List<ZodiacSignModel> signs,
    int selectedIndex,
    bool isDark,
  ) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);

    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: signs.length,
        itemBuilder: (context, index) {
          final zodiac = signs[index];
          final isSelected = selectedIndex == index;
          final localized = context.tr(zodiac.slug);
          final displayName = localized != zodiac.slug ? localized : zodiac.name;

          return GestureDetector(
            onTap: () {
              if (_selectedSignIndex != index) {
                setState(() {
                  _selectedSignIndex = index;
                });
                _loadHoroscope(zodiac.slug);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                        ? AppColors.goldPrimary.withValues(alpha: 0.15)
                        : const Color(0xFFFEA703).withValues(alpha: 0.18))
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.85)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? goldColor
                      : (isDark ? Colors.white24 : const Color(0x30D4A827)),
                  width: 1.2,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    zodiac.symbol,
                    style: TextStyle(
                      color: isSelected
                          ? goldColor
                          : (isDark ? Colors.white70 : AppColors.textSecondaryLight),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayName,
                    style: GoogleFonts.roboto(
                      color: isSelected
                          ? (isDark ? Colors.white : AppColors.textPrimaryLight)
                          : (isDark ? Colors.white70 : AppColors.textSecondaryLight),
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      shadows: textShadows,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeframeTabBar(bool isDark, ZodiacSignModel activeZodiac) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark.withValues(alpha: 0.5) : const Color(0xE8FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: isDark ? null : Border.all(color: const Color(0x30D4A827), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTimeframeTab(0, context.tr('today'), isDark, activeZodiac),
          ),
          Expanded(
            child: _buildTimeframeTab(1, context.tr('monthly'), isDark, activeZodiac),
          ),
          Expanded(
            child: _buildTimeframeTab(2, context.tr('yearly'), isDark, activeZodiac),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeTab(
    int index,
    String label,
    bool isDark,
    ZodiacSignModel activeZodiac,
  ) {
    final isSelected = _selectedTimeframe == index;
    return GestureDetector(
      onTap: () {
        if (_selectedTimeframe != index) {
          setState(() {
            _selectedTimeframe = index;
          });
          _loadHoroscope(activeZodiac.slug);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFCE7C2E) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cinzel(
              color: isSelected
                  ? Colors.black
                  : (isDark ? Colors.white : AppColors.textSecondaryLight),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
              letterSpacing: 0.8,
              shadows: isSelected ? null : AppColors.getTextShadows(isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHoroscopeCard({
    required ZodiacSignModel zodiac,
    required HoroscopeModel? horoscope,
    required bool isLoading,
    required String? error,
    required bool isDark,
  }) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);
    final textPrimary = isDark ? Colors.white : AppColors.textPrimaryLight;
    final textSecondary = isDark ? Colors.white70 : AppColors.textSecondaryLight;

    final localized = context.tr(zodiac.slug);
    final displayName = localized != zodiac.slug ? localized : zodiac.name;

    // Loading card when no data yet
    if (isLoading && horoscope == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xF5FFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white24 : goldColor.withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: goldColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aligning celestial coordinates for $displayName...',
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                color: goldColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                shadows: textShadows,
              ),
            ),
          ],
        ),
      );
    }

    // Error card when initial request fails
    if (error != null && horoscope == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xF5FFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.redAccent.withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load horoscope',
              style: GoogleFonts.cinzel(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Please check your network connection and try again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                color: textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _loadHoroscope(zodiac.slug, forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('RETRY'),
              style: OutlinedButton.styleFrom(
                foregroundColor: goldColor,
                side: BorderSide(color: goldColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Dynamic data card
    final displaySymbol = (horoscope?.symbol.isNotEmpty == true)
        ? horoscope!.symbol
        : zodiac.symbol;
    final displaySanskrit = (horoscope?.sanskrit.isNotEmpty == true)
        ? horoscope!.sanskrit
        : zodiac.sanskrit;
    final displayDateRange = (horoscope?.dateRange.isNotEmpty == true)
        ? horoscope!.dateRange
        : zodiac.dateRange;
    final displayPeriod = horoscope?.period ?? '';
    final displayElement = horoscope?.element ?? (zodiac.element.isNotEmpty ? zodiac.element : null);
    final displayPlanet = horoscope?.rulingPlanet ?? (zodiac.rulingPlanet.isNotEmpty ? zodiac.rulingPlanet : null);

    final loveRating = horoscope?.stellarRatings.love ?? 4;
    final careerRating = horoscope?.stellarRatings.career ?? 4;
    final healthRating = horoscope?.stellarRatings.health ?? 4;

    final luckyColor = horoscope?.luckyColor.isNotEmpty == true
        ? horoscope!.luckyColor
        : 'Gold';
    final luckyNumber = horoscope != null ? horoscope.luckyNumber.toString() : '7';

    final overviewText = horoscope?.sections.overview.isNotEmpty == true
        ? horoscope!.sections.overview
        : 'Cosmic alignments favor positive transformation and steady spiritual grounding.';
    final careerText = horoscope?.sections.career.isNotEmpty == true
        ? horoscope!.sections.career
        : 'Focus on thoughtful execution and clear workplace communications today.';
    final loveText = horoscope?.sections.love.isNotEmpty == true
        ? horoscope!.sections.love
        : 'Patience and warmth strengthen your closest connections.';
    final healthText = horoscope?.sections.health.isNotEmpty == true
        ? horoscope!.sections.health
        : 'Prioritize adequate hydration, restorative rest, and mindful movement.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xF5FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white24 : goldColor.withValues(alpha: 0.4),
          width: 1.0,
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
          // Subtle refresh bar if updating in background
          if (isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: goldColor.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(goldColor),
                ),
              ),
            ),

          // Sign Title, Sanskrit Name, and Dates
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: zodiac.themeColor.withValues(alpha: isDark ? 0.15 : 0.12),
                  border: Border.all(
                    color: zodiac.themeColor.withValues(alpha: isDark ? 0.4 : 0.6),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    displaySymbol,
                    style: TextStyle(
                      color: zodiac.themeColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName.toUpperCase(),
                            style: GoogleFonts.cinzel(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: textShadows,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (displaySanskrit.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            '($displaySanskrit)',
                            style: GoogleFonts.roboto(
                              color: goldColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              shadows: textShadows,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayDateRange,
                      style: GoogleFonts.roboto(
                        color: textSecondary,
                        fontSize: 11,
                        shadows: textShadows,
                      ),
                    ),
                  ],
                ),
              ),
              if (displayPeriod.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: goldColor.withValues(alpha: isDark ? 0.12 : 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: goldColor.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    displayPeriod,
                    style: GoogleFonts.roboto(
                      color: goldColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      shadows: textShadows,
                    ),
                  ),
                ),
            ],
          ),

          // Element & Ruling Planet chips if available
          if (displayElement != null || displayPlanet != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (displayElement != null && displayElement.isNotEmpty)
                  _buildAttributeChip(
                    context.tr('element'),
                    displayElement,
                    Icons.bubble_chart_rounded,
                    isDark,
                  ),
                if (displayPlanet != null && displayPlanet.isNotEmpty)
                  _buildAttributeChip(
                    context.tr('ruling_planet'),
                    displayPlanet,
                    Icons.public_rounded,
                    isDark,
                  ),
              ],
            ),
          ],

          Divider(
            color: isDark ? Colors.white12 : const Color(0x20D4A827),
            height: 32,
            thickness: 1.0,
          ),

          // Stellar Ratings
          Text(
            context.tr('todays_ratings'),
            style: GoogleFonts.cinzel(
              color: goldColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              shadows: textShadows,
            ),
          ),
          const SizedBox(height: 14),
          _buildRatingRow(
            context.tr('love_relationship'),
            loveRating,
            Colors.pinkAccent,
            isDark,
          ),
          _buildRatingRow(
            context.tr('career_finance'),
            careerRating,
            goldColor,
            isDark,
          ),
          _buildRatingRow(
            context.tr('health_energy'),
            healthRating,
            isDark ? Colors.greenAccent : const Color(0xFF2E7D32),
            isDark,
          ),
          const SizedBox(height: 24),

          // Lucky Parameters Row
          Row(
            children: [
              Expanded(
                child: _buildLuckyBox(
                  context.tr('lucky_color'),
                  luckyColor,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLuckyBox(
                  context.tr('lucky_number'),
                  luckyNumber,
                  isDark,
                ),
              ),
            ],
          ),
          Divider(
            color: isDark ? Colors.white12 : const Color(0x20D4A827),
            height: 40,
            thickness: 1.0,
          ),

          // Forecast Descriptions
          _buildForecastSection(
            context.tr('general_overview'),
            overviewText,
            isDark,
          ),
          _buildForecastSection(
            context.tr('career_money'),
            careerText,
            isDark,
          ),
          _buildForecastSection(
            context.tr('love_relationships'),
            loveText,
            isDark,
          ),
          _buildForecastSection(
            context.tr('health_wellness'),
            healthText,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeChip(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    final goldColor = AppColors.getGold(isDark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF7F4EA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0x20D4A827),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: goldColor),
          const SizedBox(width: 5),
          Text(
            '$label: ',
            style: GoogleFonts.cinzel(
              color: goldColor,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(String title, int rating, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: GoogleFonts.roboto(
                color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                shadows: AppColors.getTextShadows(isDark),
              ),
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              final active = index < rating;
              return Icon(
                active ? Icons.star_rounded : Icons.star_border_rounded,
                color: active ? color : (isDark ? Colors.white12 : Colors.black12),
                size: 16,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyBox(String label, String value, bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);
    final textPrimary = isDark ? Colors.white : AppColors.textPrimaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFFAF7F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0x25D4A827),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.cinzel(
              color: goldColor,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              shadows: textShadows,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.roboto(
              color: textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              shadows: textShadows,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastSection(String title, String content, bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);
    final textContent = isDark ? Colors.white.withValues(alpha: 0.85) : AppColors.textPrimaryLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cinzel(
              color: goldColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              shadows: textShadows,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: GoogleFonts.roboto(
              color: textContent,
              fontSize: 12,
              height: 1.5,
              shadows: textShadows,
            ),
          ),
        ],
      ),
    );
  }
}
