import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../providers/theme_provider.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  // Navigation Steps:
  // 0 = Person 1 Form
  // 1 = Person 2 Form
  // 2 = Calculating / Loading
  // 3 = Matching Result Screen
  int _currentStep = 0;

  // Person 1 Data
  final _formKey1 = GlobalKey<FormState>();
  final TextEditingController _name1Controller = TextEditingController();
  final TextEditingController _date1Controller = TextEditingController();
  final TextEditingController _time1Controller = TextEditingController();
  final TextEditingController _place1Controller = TextEditingController();
  String _gender1 = 'MALE';

  // Person 2 Data
  final _formKey2 = GlobalKey<FormState>();
  final TextEditingController _name2Controller = TextEditingController();
  final TextEditingController _date2Controller = TextEditingController();
  final TextEditingController _time2Controller = TextEditingController();
  final TextEditingController _place2Controller = TextEditingController();
  String _gender2 = 'FEMALE';

  // Loading Screen Details
  int _loadingStep = 0;
  final List<String> _loadingSteps = [
    'Comparing birth charts...',
    'Analyzing Ashtakoota Gunas...',
    'Checking Mangal Dosha match...',
    'Calculating compatibility percentage...',
    'Aligning planetary bonds...',
  ];

  @override
  void initState() {
    super.initState();
    // Video Background Initialization (for dark mode)
    _videoController =
        VideoPlayerController.asset(AppAssets.videoHomeBg)
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
    _name1Controller.dispose();
    _date1Controller.dispose();
    _time1Controller.dispose();
    _place1Controller.dispose();
    _name2Controller.dispose();
    _date2Controller.dispose();
    _time2Controller.dispose();
    _place2Controller.dispose();
    super.dispose();
  }

  // --- Pickers ---
  Future<void> _selectDate(BuildContext context, bool isPerson1, bool isDark) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 3, 15),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.goldPrimary,
                    onPrimary: Colors.black,
                    surface: AppColors.cardDark,
                    onSurface: AppColors.textPrimary,
                  )
                : const ColorScheme.light(
                    primary: AppColors.goldPrimaryDark,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.textPrimaryLight,
                  ),
            dialogTheme: DialogThemeData(
              backgroundColor: isDark ? AppColors.spaceDark : AppColors.spaceLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final formattedDate =
            "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
        if (isPerson1) {
          _date1Controller.text = formattedDate;
        } else {
          _date2Controller.text = formattedDate;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isPerson1, bool isDark) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 6, minute: 30),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.goldPrimary,
                    onPrimary: Colors.black,
                    surface: AppColors.cardDark,
                    onSurface: AppColors.textPrimary,
                  )
                : const ColorScheme.light(
                    primary: AppColors.goldPrimaryDark,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.textPrimaryLight,
                  ),
            dialogTheme: DialogThemeData(
              backgroundColor: isDark ? AppColors.spaceDark : AppColors.spaceLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isPerson1) {
          _time1Controller.text = picked.format(context);
        } else {
          _time2Controller.text = picked.format(context);
        }
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // --- Calculation Timer ---
  void _startMatching() {
    if (!_formKey2.currentState!.validate()) return;

    setState(() {
      _currentStep = 2; // Loading screen
      _loadingStep = 0;
    });

    Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_loadingStep < _loadingSteps.length - 1) {
        setState(() {
          _loadingStep++;
        });
      } else {
        timer.cancel();
        setState(() {
          _currentStep = 3; // Result screen
        });
      }
    });
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
            // Background
            // In Light Mode: LIGHT4.png (Taurus & Celestial Constellations)
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
                      AppAssets.bgLight4,
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

            // Main Content Switcher
            SafeArea(
              bottom: false,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _buildCurrentScreen(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildPerson1Form(isDark);
      case 1:
        return _buildPerson2Form(isDark);
      case 2:
        return _buildLoadingScreen(isDark);
      case 3:
        return _buildResultScreen(isDark);
      default:
        return _buildPerson1Form(isDark);
    }
  }

  // ==========================================
  // SCREEN 1: PERSON 1 INPUT FORM
  // ==========================================
  Widget _buildPerson1Form(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('person1_form'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildHeaderTitle(isDark),
            const SizedBox(height: 20),
            _buildStepIndicators(1, isDark),
            const SizedBox(height: 24),
            _buildSubHeaderBanner('♂ GROOM / PERSON 1', isDark),
            const SizedBox(height: 28),

            // Full name
            _buildLabelRow(Icons.person_outline, 'FULL NAME', isDark),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _name1Controller,
              hintText: 'Aarav Sharma',
              isDark: isDark,
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please enter full name'
                  : null,
            ),
            const SizedBox(height: 24),

            // Date of birth
            _buildLabelRow(Icons.calendar_month_outlined, 'DATE OF BIRTH', isDark),
            const SizedBox(height: 8),
            _buildClickableField(
              controller: _date1Controller,
              hintText: 'Select date of birth',
              isDark: isDark,
              onTap: () => _selectDate(context, true, isDark),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please select date of birth'
                  : null,
            ),
            const SizedBox(height: 24),

            // Time of birth
            _buildLabelRow(Icons.access_time, 'TIME OF BIRTH', isDark),
            const SizedBox(height: 8),
            _buildClickableField(
              controller: _time1Controller,
              hintText: 'Select time of birth',
              isDark: isDark,
              onTap: () => _selectTime(context, true, isDark),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please select time of birth'
                  : null,
            ),
            const SizedBox(height: 24),

            // Place of birth
            _buildLabelRow(Icons.location_on_outlined, 'PLACE OF BIRTH', isDark),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _place1Controller,
              hintText: 'Mumbai, India',
              isDark: isDark,
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please enter place of birth'
                  : null,
            ),
            const SizedBox(height: 24),

            // Gender
            _buildLabelRow(null, 'GENDER', isDark),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildGenderButton('MALE', true, isDark),
                const SizedBox(width: 10),
                _buildGenderButton('FEMALE', true, isDark),
              ],
            ),
            const SizedBox(height: 36),

            // Next button
            _buildActionButton(
              text: 'NEXT: ADD PERSON 2 →',
              onTap: () {
                if (_formKey1.currentState!.validate()) {
                  setState(() {
                    _currentStep = 1;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SCREEN 2: PERSON 2 INPUT FORM
  // ==========================================
  Widget _buildPerson2Form(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('person2_form'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildHeaderTitle(isDark),
            const SizedBox(height: 20),
            _buildStepIndicators(2, isDark),
            const SizedBox(height: 24),
            _buildSubHeaderBanner('♀ BRIDE / PERSON 2', isDark),
            const SizedBox(height: 28),

            // Full name
            _buildLabelRow(Icons.person_outline, 'FULL NAME', isDark),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _name2Controller,
              hintText: 'Priya Patel',
              isDark: isDark,
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please enter full name'
                  : null,
            ),
            const SizedBox(height: 24),

            // Date of birth
            _buildLabelRow(Icons.calendar_month_outlined, 'DATE OF BIRTH', isDark),
            const SizedBox(height: 8),
            _buildClickableField(
              controller: _date2Controller,
              hintText: 'Select date of birth',
              isDark: isDark,
              onTap: () => _selectDate(context, false, isDark),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please select date of birth'
                  : null,
            ),
            const SizedBox(height: 24),

            // Time of birth
            _buildLabelRow(Icons.access_time, 'TIME OF BIRTH', isDark),
            const SizedBox(height: 8),
            _buildClickableField(
              controller: _time2Controller,
              hintText: 'Select time of birth',
              isDark: isDark,
              onTap: () => _selectTime(context, false, isDark),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please select time of birth'
                  : null,
            ),
            const SizedBox(height: 24),

            // Place of birth
            _buildLabelRow(Icons.location_on_outlined, 'PLACE OF BIRTH', isDark),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _place2Controller,
              hintText: 'Delhi, India',
              isDark: isDark,
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please enter place of birth'
                  : null,
            ),
            const SizedBox(height: 24),

            // Gender
            _buildLabelRow(null, 'GENDER', isDark),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildGenderButton('MALE', false, isDark),
                const SizedBox(width: 10),
                _buildGenderButton('FEMALE', false, isDark),
              ],
            ),
            const SizedBox(height: 36),

            // Match buttons row: back or match
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 0;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: AppColors.getGold(isDark),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'BACK',
                      style: GoogleFonts.cinzel(
                        color: AppColors.getGold(isDark),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    text: 'MATCH KUNDALI ✨',
                    onTap: _startMatching,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SCREEN 3: CELESTIAL LOADING
  // ==========================================
  Widget _buildLoadingScreen(bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);
    final textSubtitle = isDark ? Colors.white70 : AppColors.textSecondaryLight;

    return Center(
      key: const ValueKey('loading_screen'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: Image.asset(
                AppAssets.rashiChakra,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.auto_awesome,
                  color: goldColor,
                  size: 64,
                ),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              _loadingSteps[_loadingStep].toUpperCase(),
              style: GoogleFonts.cinzel(
                color: goldColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Aligning celestial bonds between ${_name1Controller.text} and ${_name2Controller.text}',
              style: GoogleFonts.roboto(
                color: textSubtitle,
                fontSize: 13,
                shadows: textShadows,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 150,
                height: 4,
                child: LinearProgressIndicator(
                  value: (_loadingStep + 1) / _loadingSteps.length,
                  backgroundColor: isDark ? AppColors.borderDark : const Color(0x30D4A827),
                  color: goldColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SCREEN 4: MATCHING RESULT SCREEN
  // ==========================================
  Widget _buildResultScreen(bool isDark) {
    final name1 = _name1Controller.text.isNotEmpty
        ? _name1Controller.text.split(' ').first
        : 'AARAV';
    final name2 = _name2Controller.text.isNotEmpty
        ? _name2Controller.text.split(' ').first
        : 'PRIYA';

    final goldColor = AppColors.getGold(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textShadows = AppColors.getTextShadows(isDark);

    return SingleChildScrollView(
      key: const ValueKey('result_screen'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top navigation row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentStep = 1;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new,
                      color: goldColor,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Back',
                      style: GoogleFonts.roboto(
                        color: goldColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        shadows: textShadows,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: goldColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: goldColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.file_download_outlined,
                    color: goldColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Title
          Text(
            'MATCHING RESULT',
            style: GoogleFonts.cinzel(
              color: textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              shadows: textShadows,
            ),
          ),
          const SizedBox(height: 24),

          // 3. Circular Match Score Card
          _buildScoreVisualCard(name1, name2, isDark),
          const SizedBox(height: 20),

          // 4. Description block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xF5FFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white24 : goldColor.withValues(alpha: 0.35),
                width: 1.0,
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
            child: Text(
              'This pairing shows strong cosmic alignment — deep emotional resonance, complementary temperaments, and a shared spiritual path.',
              style: GoogleFonts.roboto(
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                fontSize: 13,
                height: 1.4,
                shadows: textShadows,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 5. 36 Guna Matching Table
          _buildGunaMatchingSection(isDark),
          const SizedBox(height: 20),

          // 6. Mangal Dosha Status Card
          _buildMangalDoshaCard(isDark),
          const SizedBox(height: 32),

          // 7. Restart Match
          GestureDetector(
            onTap: () {
              setState(() {
                _currentStep = 0;
                _name1Controller.clear();
                _date1Controller.clear();
                _time1Controller.clear();
                _place1Controller.clear();
                _name2Controller.clear();
                _date2Controller.clear();
                _time2Controller.clear();
                _place2Controller.clear();
              });
            },
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1B30) : const Color(0xFFFAF7F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0x40D4A827),
                  width: 1.5,
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
              child: Center(
                child: Text(
                  'MATCH ANOTHER KUNDALI',
                  style: GoogleFonts.cinzel(
                    color: goldColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildScoreVisualCard(String name1, String name2, bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);
    final textPrimary = isDark ? Colors.white : AppColors.textPrimaryLight;
    final textSecondary = isDark ? Colors.white70 : AppColors.textSecondaryLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xF5FFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white24 : goldColor.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Left Person details
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFFAF7F0),
                        border: Border.all(
                          color: goldColor.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person_outline,
                          color: goldColor,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name1.toUpperCase(),
                      style: GoogleFonts.cinzel(
                        color: textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        shadows: textShadows,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Scorpio ♏',
                      style: GoogleFonts.roboto(
                        color: textSecondary,
                        fontSize: 10,
                        shadows: textShadows,
                      ),
                    ),
                  ],
                ),
              ),

              // Center Circular Indicator
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: 28 / 36,
                          strokeWidth: 6,
                          backgroundColor: isDark ? Colors.white12 : const Color(0x20D4A827),
                          color: isDark ? const Color(0xFF00FFCC) : const Color(0xFF00BFA5),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '28',
                            style: GoogleFonts.roboto(
                              color: textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: textShadows,
                            ),
                          ),
                          Text(
                            'OUT OF 36',
                            style: GoogleFonts.roboto(
                              color: textSecondary,
                              fontSize: 8,
                              shadows: textShadows,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Right Person details
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFFAF7F0),
                        border: Border.all(
                          color: goldColor.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.favorite_border_rounded,
                          color: goldColor,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name2.toUpperCase(),
                      style: GoogleFonts.cinzel(
                        color: textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        shadows: textShadows,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Taurus ♉',
                      style: GoogleFonts.roboto(
                        color: textSecondary,
                        fontSize: 10,
                        shadows: textShadows,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: isDark ? 0.12 : 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Text(
              'EXCELLENT MATCH',
              style: GoogleFonts.cinzel(
                color: isDark ? Colors.greenAccent : const Color(0xFF2E7D32),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGunaMatchingSection(bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);
    final textPrimary = isDark ? Colors.white : AppColors.textPrimaryLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xF5FFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white24 : goldColor.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '36 GUNA MATCHING',
            style: GoogleFonts.cinzel(
              color: goldColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              shadows: textShadows,
            ),
          ),
          const SizedBox(height: 16),
          // Guna table rows
          _buildGunaRow('Varna', 'Spiritual compatibility', 1, 1, isDark),
          _buildGunaRow('Vasya', 'Power & dominance', 2, 2, isDark),
          _buildGunaRow('Tara', 'Destiny & fortune', 3, 3, isDark),
          _buildGunaRow('Yoni', 'Nature & instinct', 4, 3, isDark),
          _buildGunaRow('Graha Maitri', 'Planet friendship', 5, 4, isDark),
          _buildGunaRow('Gana', 'Temperament match', 6, 5, isDark),
          _buildGunaRow('Bhakoot', 'Love & prosperity', 7, 6, isDark),
          _buildGunaRow('Nadi', 'Health & progeny', 8, 4, isDark),

          Divider(
            color: isDark ? AppColors.borderDark : const Color(0x20D4A827),
            height: 24,
            thickness: 1.2,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL SCORE',
                style: GoogleFonts.cinzel(
                  color: goldColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  shadows: textShadows,
                ),
              ),
              Text(
                '28/36',
                style: GoogleFonts.roboto(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: textShadows,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGunaRow(String gunaName, String desc, int max, int obtained, bool isDark) {
    Color barColor = isDark ? const Color(0xFF00FFCC) : const Color(0xFF00BFA5);
    if (obtained < max / 2) {
      barColor = AppColors.goldOrange;
    } else if (obtained < max) {
      barColor = AppColors.getGold(isDark);
    }

    final textShadows = AppColors.getTextShadows(isDark);
    final textPrimary = isDark ? Colors.white : AppColors.textPrimaryLight;
    final textDesc = isDark ? Colors.white54 : AppColors.textMutedLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gunaName,
                  style: GoogleFonts.roboto(
                    color: textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    shadows: textShadows,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.roboto(
                    color: textDesc,
                    fontSize: 10,
                    shadows: textShadows,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$max',
              style: GoogleFonts.roboto(
                color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                fontSize: 12,
                shadows: textShadows,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$obtained',
              style: GoogleFonts.roboto(
                color: barColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                shadows: textShadows,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 8,
                color: isDark ? Colors.white12 : const Color(0x20D4A827),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: obtained / max.toDouble(),
                  child: Container(color: barColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMangalDoshaCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xF5FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.35),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: isDark ? Colors.greenAccent : const Color(0xFF2E7D32),
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MANGAL DOSHA COMPATIBLE',
                  style: GoogleFonts.cinzel(
                    color: isDark ? Colors.greenAccent : const Color(0xFF2E7D32),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    shadows: AppColors.getTextShadows(isDark),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Neither person has Mangal Dosha. This is excellent for matrimonial compatibility and long-term wellbeing.',
                  style: GoogleFonts.roboto(
                    color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                    fontSize: 11,
                    height: 1.3,
                    shadows: AppColors.getTextShadows(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Help Widgets for Forms ---
  Widget _buildHeaderTitle(bool isDark) {
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textShadows = AppColors.getTextShadows(isDark);
    final textSubtitle = isDark ? Colors.white70 : AppColors.textSecondaryLight;

    return Center(
      child: Column(
        children: [
          Text(
            'KUNDALI MATCHING',
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
            'Check matrimonial compatibility between two birth charts',
            style: GoogleFonts.roboto(
              color: textSubtitle,
              fontSize: 11,
              shadows: textShadows,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicators(int activeStep, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark.withValues(alpha: 0.5) : const Color(0xE8FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: isDark ? null : Border.all(color: const Color(0x30D4A827), width: 1),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStepCapsule(1, 'PERSON 1', activeStep >= 1, isDark)),
          Expanded(child: _buildStepCapsule(2, 'PERSON 2', activeStep >= 2, isDark)),
        ],
      ),
    );
  }

  Widget _buildStepCapsule(int step, String label, bool isDoneOrActive, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isDoneOrActive ? const Color(0xFFCE7C2E) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDoneOrActive
                  ? Colors.black
                  : (isDark ? Colors.white24 : Colors.black12),
            ),
            child: Center(
              child: Text(
                '$step',
                style: TextStyle(
                  color: isDoneOrActive
                      ? Colors.white
                      : (isDark ? Colors.white70 : AppColors.textSecondaryLight),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.cinzel(
              color: isDoneOrActive
                  ? Colors.black
                  : (isDark ? Colors.white60 : AppColors.textSecondaryLight),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeaderBanner(String text, bool isDark) {
    final goldColor = AppColors.getGold(isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: goldColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: goldColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.cinzel(
            color: goldColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            shadows: AppColors.getTextShadows(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildLabelRow(IconData? icon, String text, bool isDark) {
    final goldColor = AppColors.getGold(isDark);

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: goldColor, size: 16),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: GoogleFonts.cinzel(
            color: goldColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            shadows: AppColors.getTextShadows(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    required String? Function(String?)? validator,
  }) {
    final goldColor = AppColors.getGold(isDark);
    final textColor = AppColors.getTextPrimary(isDark);
    final hintColor = isDark ? Colors.white60 : AppColors.textMutedLight;

    return TextFormField(
      controller: controller,
      validator: validator,
      style: GoogleFonts.roboto(color: textColor, fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.roboto(
          color: hintColor,
          fontSize: 15,
          shadows: AppColors.getTextShadows(isDark),
        ),
        fillColor: isDark ? Colors.transparent : Colors.white.withValues(alpha: 0.65),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: isDark ? goldColor.withValues(alpha: 0.25) : const Color(0x35D4A827),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: goldColor,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildClickableField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    required VoidCallback onTap,
    required String? Function(String?)? validator,
  }) {
    final goldColor = AppColors.getGold(isDark);
    final textColor = AppColors.getTextPrimary(isDark);
    final hintColor = isDark ? Colors.white60 : AppColors.textMutedLight;

    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          validator: validator,
          style: GoogleFonts.roboto(color: textColor, fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.roboto(
              color: hintColor,
              fontSize: 15,
              shadows: AppColors.getTextShadows(isDark),
            ),
            fillColor: isDark ? Colors.transparent : Colors.white.withValues(alpha: 0.65),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: isDark ? goldColor.withValues(alpha: 0.25) : const Color(0x35D4A827),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: goldColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderButton(String gender, bool isPerson1, bool isDark) {
    final isSelected = isPerson1 ? _gender1 == gender : _gender2 == gender;
    final goldColor = AppColors.getGold(isDark);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isPerson1) {
              _gender1 = gender;
            } else {
              _gender2 = gender;
            }
          });
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFCE7C2E)
                : (isDark ? Colors.transparent : Colors.white.withValues(alpha: 0.7)),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : goldColor.withValues(alpha: isDark ? 0.25 : 0.4),
              width: 1.2,
            ),
          ),
          child: Center(
            child: Text(
              gender,
              style: GoogleFonts.cinzel(
                color: isSelected
                    ? Colors.black
                    : (isDark ? Colors.white : AppColors.textPrimaryLight),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.5,
                shadows: isSelected ? null : AppColors.getTextShadows(isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
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
            text,
            style: GoogleFonts.cinzel(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
