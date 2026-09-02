import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../providers/theme_provider.dart';

class ZodiacSign {
  final String name;
  final String sanskritName;
  final String symbol;
  final String dateRange;
  final Color themeColor;
  final String overview;
  final String career;
  final String love;
  final String health;
  final int loveRating;
  final int careerRating;
  final int healthRating;
  final String luckyColor;
  final int luckyNumber;

  const ZodiacSign({
    required this.name,
    required this.sanskritName,
    required this.symbol,
    required this.dateRange,
    required this.themeColor,
    required this.overview,
    required this.career,
    required this.love,
    required this.health,
    required this.loveRating,
    required this.careerRating,
    required this.healthRating,
    required this.luckyColor,
    required this.luckyNumber,
  });
}

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

  // Selected timeframe tab (0 = Today, 1 = Weekly, 2 = Yearly)
  int _selectedTimeframe = 0;

  final List<ZodiacSign> _zodiacs = const [
    ZodiacSign(
      name: 'Aries',
      sanskritName: 'Mesha',
      symbol: '♈',
      dateRange: 'Mar 21 - Apr 19',
      themeColor: Colors.redAccent,
      overview: 'Today brings fresh opportunities to assert yourself. Mars in your sign fuels your passion and determination. Trust your gut instincts and take bold steps forward.',
      career: 'A collaborative project might require your leadership. Keep communication channels open and clear to avoid misunderstandings.',
      love: 'Passion is high today. If you are in a relationship, share your long-term goals with your partner. Singles may find an unexpected attraction.',
      health: 'Energy levels are solid, but avoid overexertion. Ensure you balance active work with deep rest.',
      loveRating: 4,
      careerRating: 5,
      healthRating: 4,
      luckyColor: 'Red',
      luckyNumber: 9,
    ),
    ZodiacSign(
      name: 'Taurus',
      sanskritName: 'Vrishabha',
      symbol: '♉',
      dateRange: 'Apr 20 - May 20',
      themeColor: Colors.green,
      overview: 'Focus on stability and ground your thoughts. Venus supports your creative endeavors today. Patience will yield rewards in both personal and professional spheres.',
      career: 'Financial planning is highly favored today. Take a second look at your monthly budget before making major business investments.',
      love: 'Comfort and warmth dominate your relationship sector. A quiet, cozy evening with your loved one will strengthen your emotional bond.',
      health: 'Mindfulness and breathing exercises will help relieve minor tension in the neck and shoulders.',
      loveRating: 5,
      careerRating: 4,
      healthRating: 4,
      luckyColor: 'Emerald Green',
      luckyNumber: 6,
    ),
    ZodiacSign(
      name: 'Gemini',
      sanskritName: 'Mithuna',
      symbol: '♊',
      dateRange: 'May 21 - Jun 20',
      themeColor: Colors.cyan,
      overview: 'Your intellectual curiosity is peaked today. Engaging in stimulating conversations will bring new ideas and helpful alliances. Keep your mind open to criticism.',
      career: 'Multi-tasking is your strength today. Just make sure to finish one primary goal before moving to next project.',
      love: 'Playful banter and lighthearted flirtation keep your spirits high. Ensure you also express deep emotional sincerity.',
      health: 'Mental fatigue is possible due to excessive screen time. Rest your eyes and take short walking breaks.',
      loveRating: 4,
      careerRating: 4,
      healthRating: 3,
      luckyColor: 'Yellow',
      luckyNumber: 5,
    ),
    ZodiacSign(
      name: 'Cancer',
      sanskritName: 'Karka',
      symbol: '♋',
      dateRange: 'Jun 21 - Jul 22',
      themeColor: Colors.purpleAccent,
      overview: 'Your emotional sensitivity is your superpower today. You are highly receptive to the needs of others. Trust your instincts when dealing with complex family situations.',
      career: 'A nurturing work environment helps you thrive. Support a colleague who might be struggling with their workload.',
      love: 'Deep, emotional conversations are favored. Share your inner feelings to build a strong foundation of trust with your partner.',
      health: 'Paying attention to your digestive health will prevent discomfort. Home-cooked, warm meals are recommended.',
      loveRating: 5,
      careerRating: 4,
      healthRating: 4,
      luckyColor: 'Silver / White',
      luckyNumber: 2,
    ),
    ZodiacSign(
      name: 'Leo',
      sanskritName: 'Simha',
      symbol: '♌',
      dateRange: 'Jul 23 - Aug 22',
      themeColor: Colors.amber,
      overview: 'Your natural charisma shines bright today. Sun, your ruler, gives you the strength to overcome minor obstacles. Share your warmth and inspire those around you.',
      career: 'Your efforts are finally noticed by seniors. It is an excellent day to present fresh ideas or pitch creative projects.',
      love: 'Generosity and loyalty strengthen your romance. Surprise your partner with a thoughtful gesture to show appreciation.',
      health: 'Cardiovascular energy is high. An intense workout or a brisk walk outdoors will boost your mood and metabolism.',
      loveRating: 4,
      careerRating: 5,
      healthRating: 5,
      luckyColor: 'Gold',
      luckyNumber: 1,
    ),
    ZodiacSign(
      name: 'Virgo',
      sanskritName: 'Kanya',
      symbol: '♍',
      dateRange: 'Aug 23 - Sep 22',
      themeColor: Colors.orange,
      overview: 'Attention to detail will save the day. Your analytical skills help you solve a complex issue that others missed. Stay organized and declutter your environment.',
      career: 'Focus on refining your strategies. Quality is far more important than quantity in your output today.',
      love: 'Practical expressions of love are highly appreciated. Helping your partner with chores or tasks speaks louder than words today.',
      health: 'Maintain a clean diet. Avoiding processed foods will keep your energy levels steady throughout the afternoon.',
      loveRating: 4,
      careerRating: 5,
      healthRating: 4,
      luckyColor: 'Navy Blue',
      luckyNumber: 3,
    ),
    ZodiacSign(
      name: 'Libra',
      sanskritName: 'Tula',
      symbol: '♎',
      dateRange: 'Sep 23 - Oct 22',
      themeColor: Colors.pinkAccent,
      overview: 'Balance and harmony are your primary goals today. Seek compromise instead of arguments. Art, music, and beautiful environments will lift your spirits.',
      career: 'Negotiations and client meetings go extremely well. Your pleasant demeanor helps build trust and reach mutually beneficial outcomes.',
      love: 'Romance is in the air. A sweet, harmonious connection is highlighted. Share soft moments and appreciate each other\'s presence.',
      health: 'Keep hydration levels high. Minor back stiffness can be relieved with gentle yoga stretches.',
      loveRating: 5,
      careerRating: 4,
      healthRating: 4,
      luckyColor: 'Pastel Pink',
      luckyNumber: 7,
    ),
    ZodiacSign(
      name: 'Scorpio',
      sanskritName: 'Vrishchika',
      symbol: '♏',
      dateRange: 'Oct 23 - Nov 21',
      themeColor: Colors.deepPurple,
      overview: 'Your intensity and focus are unmatched today. You can see through facades and uncover truths. Trust your intuition and keep your strategies confidential.',
      career: 'A research-based project yields valuable data. Dive deep into problems and don\'t stop until you find the source.',
      love: 'Intimate and passionate dynamics define your romance. Authentic connections matter more to you than superficial conversations.',
      health: 'Repressed stress can affect your well-being. Dedicate time to intense physical workouts or deep meditation to release energy.',
      loveRating: 4,
      careerRating: 4,
      healthRating: 5,
      luckyColor: 'Maroon',
      luckyNumber: 8,
    ),
    ZodiacSign(
      name: 'Sagittarius',
      sanskritName: 'Dhanu',
      symbol: '♐',
      dateRange: 'Nov 22 - Dec 21',
      themeColor: Colors.blueAccent,
      overview: 'Your optimistic spirit is contagious today. Expanding your boundaries through reading, planning a trip, or philosophy brings joy. Embrace new opportunities.',
      career: 'A broad perspective helps you solve a persistent team problem. Focus on the big picture instead of getting bogged down in minor details.',
      love: 'Adventure and exploration are highlight elements. Plan a fun outing or try a new activity together to spark romance.',
      health: 'Outdoor activities are highly beneficial for your physical and mental health. Connect with nature.',
      loveRating: 5,
      careerRating: 4,
      healthRating: 5,
      luckyColor: 'Purple',
      luckyNumber: 3,
    ),
    ZodiacSign(
      name: 'Capricorn',
      sanskritName: 'Makara',
      symbol: '♑',
      dateRange: 'Dec 22 - Jan 19',
      themeColor: Colors.blueGrey,
      overview: 'Discipline and focus yield massive rewards today. Saturn, your ruler, supports structural planning and career building. Stay dedicated to your long-term goals.',
      career: 'Your persistent hard work is noticed by higher authorities. Remain humble and keep delivering consistent performance.',
      love: 'Reliability and commitment are key themes. Being a steady pillar of support for your partner deepens relationship security.',
      health: 'Pay attention to joint health. Stretching and joint strengthening exercises are recommended.',
      loveRating: 4,
      careerRating: 5,
      healthRating: 4,
      luckyColor: 'Dark Grey / Brown',
      luckyNumber: 4,
    ),
    ZodiacSign(
      name: 'Aquarius',
      sanskritName: 'Kumbha',
      symbol: '♒',
      dateRange: 'Jan 20 - Feb 18',
      themeColor: Colors.indigoAccent,
      overview: 'Innovative thinking and community values define your day. Share your unique perspective with friends or groups. Your forward-looking views inspire progress.',
      career: 'Technology or collaborative brainstorming helps resolve a complex block. Don\'t be afraid to propose unconventional ideas.',
      love: 'Friendship forms the base of your romantic connections. Enjoy intellectually stimulating conversations together.',
      health: 'Restless mind can affect sleep. Limit screen time before bed and try reading a book.',
      loveRating: 4,
      careerRating: 4,
      healthRating: 3,
      luckyColor: 'Electric Blue',
      luckyNumber: 8,
    ),
    ZodiacSign(
      name: 'Pisces',
      sanskritName: 'Meena',
      symbol: '♓',
      dateRange: 'Feb 19 - Mar 20',
      themeColor: Color(0xFF9C27B0),
      overview: 'Dreamy and highly intuitive vibes surround you. Trust your creative impulses and make time for artistic expressions. Your spiritual connection is very strong today.',
      career: 'Trust your creative instincts. An empathetic approach to team conflicts helps bring smooth alignment.',
      love: 'Romantic ideals and emotional sensitivity dominate. Share your dreams and show soft, gentle care to your partner.',
      health: 'Take gentle care of your feet and ensure proper rest. A warm bath or foot massage will bring relaxation.',
      loveRating: 5,
      careerRating: 4,
      healthRating: 4,
      luckyColor: 'Sea Green / Yellow',
      luckyNumber: 7,
    ),
  ];

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final activeZodiac = _zodiacs[_selectedSignIndex];

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            // In Light Mode: LIGHT3.png (Rashi Chakra backdrop)
            // In Dark Mode: Video / home_bg.png
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

            // Scrollable Content
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Header Brand
                    Center(child: _buildHeaderTitle(isDark)),
                    const SizedBox(height: 24),

                    // Zodiac Sign Selector
                    _buildHorizontalZodiacSelector(isDark),
                    const SizedBox(height: 24),

                    // Timeframe Tabs (Today, Weekly, Yearly)
                    _buildTimeframeTabBar(isDark),
                    const SizedBox(height: 24),

                    // Main Content Card
                    _buildHoroscopeCard(activeZodiac, isDark),
                    const SizedBox(height: 24),
                  ],
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
          'DAILY HOROSCOPE',
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
          'Unlock your celestial forecasts and daily planetary ratings',
          style: GoogleFonts.roboto(
            color: subtitleColor,
            fontSize: 11,
            shadows: textShadows,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalZodiacSelector(bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);

    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _zodiacs.length,
        itemBuilder: (context, index) {
          final zodiac = _zodiacs[index];
          final isSelected = _selectedSignIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSignIndex = index;
              });
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
                  color: isSelected ? goldColor : (isDark ? Colors.white24 : const Color(0x30D4A827)),
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
                      color: isSelected ? goldColor : (isDark ? Colors.white70 : AppColors.textSecondaryLight),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    zodiac.name,
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

  Widget _buildTimeframeTabBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark.withValues(alpha: 0.5) : const Color(0xE8FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: isDark ? null : Border.all(color: const Color(0x30D4A827), width: 1),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTimeframeTab(0, 'TODAY', isDark)),
          Expanded(child: _buildTimeframeTab(1, 'WEEKLY', isDark)),
          Expanded(child: _buildTimeframeTab(2, 'YEARLY', isDark)),
        ],
      ),
    );
  }

  Widget _buildTimeframeTab(int index, String label, bool isDark) {
    final isSelected = _selectedTimeframe == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeframe = index;
        });
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

  Widget _buildHoroscopeCard(ZodiacSign zodiac, bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);
    final textPrimary = isDark ? Colors.white : AppColors.textPrimaryLight;
    final textSecondary = isDark ? Colors.white70 : AppColors.textSecondaryLight;

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
          // Sign Title, Sanskrit Name, and Dates
          Row(
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
                    zodiac.symbol,
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
                        Text(
                          zodiac.name.toUpperCase(),
                          style: GoogleFonts.cinzel(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: textShadows,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${zodiac.sanskritName})',
                          style: GoogleFonts.roboto(
                            color: goldColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            shadows: textShadows,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      zodiac.dateRange,
                      style: GoogleFonts.roboto(
                        color: textSecondary,
                        fontSize: 11,
                        shadows: textShadows,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(
            color: isDark ? Colors.white12 : const Color(0x20D4A827),
            height: 32,
            thickness: 1.0,
          ),

          // Daily Ratings / Progress
          Text(
            'TODAY\'S STELLAR RATINGS',
            style: GoogleFonts.cinzel(
              color: goldColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              shadows: textShadows,
            ),
          ),
          const SizedBox(height: 14),
          _buildRatingRow('Love & Relationship', zodiac.loveRating, Colors.pinkAccent, isDark),
          _buildRatingRow('Career & Finance', zodiac.careerRating, goldColor, isDark),
          _buildRatingRow('Health & Energy', zodiac.healthRating, isDark ? Colors.greenAccent : const Color(0xFF2E7D32), isDark),
          const SizedBox(height: 24),

          // Lucky Parameters Row
          Row(
            children: [
              Expanded(
                child: _buildLuckyBox('LUCKY COLOR', zodiac.luckyColor, isDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLuckyBox('LUCKY NUMBER', zodiac.luckyNumber.toString(), isDark),
              ),
            ],
          ),
          Divider(
            color: isDark ? Colors.white12 : const Color(0x20D4A827),
            height: 40,
            thickness: 1.0,
          ),

          // Forecast Descriptions
          _buildForecastSection('GENERAL OVERVIEW', zodiac.overview, isDark),
          _buildForecastSection('CAREER & MONEY', zodiac.career, isDark),
          _buildForecastSection('LOVE & RELATIONSHIPS', zodiac.love, isDark),
          _buildForecastSection('HEALTH & WELLNESS', zodiac.health, isDark),
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
