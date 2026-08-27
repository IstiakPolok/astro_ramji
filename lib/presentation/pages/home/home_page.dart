import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
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
        VideoPlayerController.asset('assets/videos/homescreenbg.mp4')
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
    return Scaffold(
      backgroundColor: AppColors.spaceDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Breathtaking Cosmic Astrological Background (Video or Image Fallback)
            Positioned.fill(
              child: _isVideoInitialized && _videoController != null
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController!.value.size.width,
                        height: _videoController!.value.size.height,
                        child: VideoPlayer(_videoController!),
                      ),
                    )
                  : Image.asset(
                      'assets/images/background/home_bg.png',
                      fit: BoxFit.cover,
                    ),
            ),
            // Dark overlay for readability
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.20)),
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
                            // Top Section: Profile Info
                            _buildProfileHeader(),
                            const SizedBox(height: 20),

                            // Quote section
                            _buildQuoteSection(),
                            const SizedBox(height: 20),

                            // Today's Forecast Button
                            _buildForecastButton(),
                            const SizedBox(height: 24),

                            // Today's Panchang Card
                            _buildPanchangCard(),
                            const SizedBox(height: 24),

                            // Quick Actions Header
                            _buildSectionHeader('QUICK ACTIONS'),
                            const SizedBox(height: 16),

                            // Quick Actions Grid (Row of 2)
                            _buildQuickActionsRow1(),
                            const SizedBox(height: 24),

                            // Jupiter Mahadasha Card
                            _buildMahadashaCard(),
                            const SizedBox(height: 24),

                            // Quick Actions Header 2
                            _buildSectionHeader('QUICK ACTIONS'),
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

  // --- Profile Header ---
  Widget _buildProfileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AARAV SHARMA',
          style: GoogleFonts.cinzel(
            color: AppColors.goldPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Monday, 11 August 2026',
          style: GoogleFonts.roboto(
            color: const Color(0xFFFF0000), // Red/Orange Date
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // --- Quote Section ---
  Widget _buildQuoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '“',
          style: GoogleFonts.cinzel(
            color: AppColors.goldPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 0.8,
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -12),
          child: Text(
            'The cosmos holds the map,\nyour journey writes the story.',
            style: GoogleFonts.roboto(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              height: 1.4,
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
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
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
  Widget _buildPanchangCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x770F0B1E), // Semi-transparent nebula color
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: 0.25),
          width: 1.5,
        ),
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
                  color: AppColors.goldPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.textSecondary,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '11 Aug 2026',
                    style: GoogleFonts.roboto(
                      color: AppColors.textSecondary,
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
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPanchangItem(
                  'Nakshatra',
                  'Ashlesha',
                  Icons.star_border_rounded,
                  Colors.greenAccent,
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
                  Colors.purpleAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPanchangItem(
                  'Karana',
                  '07:12pm',
                  Icons.circle_outlined,
                  Colors.orangeAccent,
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
                  Colors.yellowAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPanchangItem(
                  'Sunset',
                  '07:12pm',
                  Icons.wb_twilight_outlined,
                  Colors.blueAccent,
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
                  Colors.pinkAccent,
                ),
              ),
              const Expanded(
                flex: 1,
                child: SizedBox(),
              ), // spacer to match 2-column width exactly
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
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0C091A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: Row(
        children: [
          // Circular icon container
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
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
                    color: AppColors.goldPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
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
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.cinzel(
        color: AppColors.goldPrimary,
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
              'assets/images/Component/kundalibutton.png',
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
              'assets/images/Component/kundalimatchingbutton.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  // --- Jupiter Mahadasha Card ---
  Widget _buildMahadashaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x770F0B1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Jupiter Planet Image
          Image.asset(
            'assets/images/Component/jupitar.png',
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
                    color: AppColors.goldPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2023–2039 · Currently active',
                  style: GoogleFonts.roboto(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 8),
                // Progress Bar
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.borderDark,
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
            'assets/images/Component/rashichakra.png',
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
              'assets/images/Component/nomangaldosha.png',
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
              'assets/images/Component/sadesati.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
