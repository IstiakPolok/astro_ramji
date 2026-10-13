import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/birth_profile_model.dart';
import '../../../data/models/location_model.dart';
import '../../../data/models/match_model.dart';
import '../../providers/theme_provider.dart';
import '../../providers/astrology_api_provider.dart';
import '../../widgets/location_autocomplete_field.dart';

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
  DateTime? _pickedDate1;
  TimeOfDay? _pickedTime1;
  LocationModel? _location1;
  String _gender1 = 'MALE';

  // Person 2 Data
  final _formKey2 = GlobalKey<FormState>();
  final TextEditingController _name2Controller = TextEditingController();
  final TextEditingController _date2Controller = TextEditingController();
  final TextEditingController _time2Controller = TextEditingController();
  final TextEditingController _place2Controller = TextEditingController();
  DateTime? _pickedDate2;
  TimeOfDay? _pickedTime2;
  LocationModel? _location2;
  String _gender2 = 'FEMALE';

  // Loading Screen Details
  int _loadingStep = 0;

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
          _pickedDate1 = picked;
          _date1Controller.text = formattedDate;
        } else {
          _pickedDate2 = picked;
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
          _pickedTime1 = picked;
          _time1Controller.text = picked.format(context);
        } else {
          _pickedTime2 = picked;
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

  // --- Calculation Timer & API Call ---
  void _startMatching() async {
    if (!_formKey2.currentState!.validate()) return;

    setState(() {
      _currentStep = 2; // Loading screen
      _loadingStep = 0;
    });

    final apiProvider = Provider.of<AstrologyApiProvider>(context, listen: false);

    // If place was typed without selecting autocomplete, dynamically resolve coordinates from API
    if (_location1 == null && _place1Controller.text.trim().isNotEmpty) {
      try {
        final results = await apiProvider.searchLocationsDirect(_place1Controller.text.trim());
        if (results.isNotEmpty && results.first.placeId.isNotEmpty) {
          _location1 = await apiProvider.getLocationDetails(results.first.placeId);
        }
      } catch (_) {}
    }

    if (_location2 == null && _place2Controller.text.trim().isNotEmpty) {
      try {
        final results = await apiProvider.searchLocationsDirect(_place2Controller.text.trim());
        if (results.isNotEmpty && results.first.placeId.isNotEmpty) {
          _location2 = await apiProvider.getLocationDetails(results.first.placeId);
        }
      } catch (_) {}
    }

    String formatDob(DateTime? dt, String fallback) {
      if (dt != null) {
        return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      }
      return fallback;
    }

    String formatTob(TimeOfDay? tod, String fallback) {
      if (tod != null) {
        return '${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}:00';
      }
      return fallback;
    }

    final p1Name = _name1Controller.text.trim();
    final p2Name = _name2Controller.text.trim();

    final boyData = RawBirthData(
      name: p1Name.isNotEmpty ? p1Name : 'Partner 1',
      dateOfBirth: formatDob(_pickedDate1, '1995-01-01'),
      timeOfBirth: formatTob(_pickedTime1, '12:00:00'),
      latitude: _location1?.latitude ?? 28.6139,
      longitude: _location1?.longitude ?? 77.2090,
      timezone: _location1?.timezoneId ?? 'Asia/Kolkata',
      gender: _gender1,
    );

    final girlData = RawBirthData(
      name: p2Name.isNotEmpty ? p2Name : 'Partner 2',
      dateOfBirth: formatDob(_pickedDate2, '1996-01-01'),
      timeOfBirth: formatTob(_pickedTime2, '12:00:00'),
      latitude: _location2?.latitude ?? 28.6139,
      longitude: _location2?.longitude ?? 77.2090,
      timezone: _location2?.timezoneId ?? 'Asia/Kolkata',
      gender: _gender2,
    );

    final matchFuture = apiProvider.matchProfiles(boyData: boyData, girlData: girlData);

    Timer.periodic(const Duration(milliseconds: 600), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_loadingStep < 4) {
        setState(() {
          _loadingStep++;
        });
      } else {
        timer.cancel();
        await matchFuture;
        if (mounted) {
          setState(() {
            _currentStep = 3; // Result screen
          });
        }
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
            _buildSubHeaderBanner(context.tr('groom_header'), isDark),
            const SizedBox(height: 28),

            // Full name
            _buildLabelRow(Icons.person_outline, context.tr('full_name'), isDark),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _name1Controller,
              hintText: context.tr('full_name_hint'),
              isDark: isDark,
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please enter full name'
                  : null,
            ),
            const SizedBox(height: 24),

            // Date of birth
            _buildLabelRow(Icons.calendar_month_outlined, context.tr('date_of_birth'), isDark),
            const SizedBox(height: 8),
            _buildClickableField(
              controller: _date1Controller,
              hintText: context.tr('select_date_hint'),
              isDark: isDark,
              onTap: () => _selectDate(context, true, isDark),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please select date of birth'
                  : null,
            ),
            const SizedBox(height: 24),

            // Time of birth
            _buildLabelRow(Icons.access_time, context.tr('time_of_birth'), isDark),
            const SizedBox(height: 8),
            _buildClickableField(
              controller: _time1Controller,
              hintText: context.tr('select_time_hint'),
              isDark: isDark,
              onTap: () => _selectTime(context, true, isDark),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please select time of birth'
                  : null,
            ),
            const SizedBox(height: 24),

            // Place of birth
            _buildLabelRow(Icons.location_on_outlined, context.tr('place_of_birth'), isDark),
            const SizedBox(height: 8),
            LocationAutocompleteField(
              controller: _place1Controller,
              label: '',
              hint: 'Mumbai, India',
              isDark: isDark,
              onLocationSelected: (loc) {
                setState(() {
                  _location1 = loc;
                });
              },
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please enter place of birth'
                  : null,
            ),
            const SizedBox(height: 24),

            // Gender
            _buildLabelRow(null, context.tr('gender'), isDark),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildGenderButton('MALE', context.tr('gender_male'), true, isDark),
                const SizedBox(width: 10),
                _buildGenderButton('FEMALE', context.tr('gender_female'), true, isDark),
              ],
            ),
            const SizedBox(height: 36),

            // Next button
            _buildActionButton(
              text: context.tr('next_person_2'),
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
            _buildSubHeaderBanner(context.tr('bride_header'), isDark),
            const SizedBox(height: 28),

            // Full name
            _buildLabelRow(Icons.person_outline, context.tr('full_name'), isDark),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _name2Controller,
              hintText: context.tr('full_name_hint'),
              isDark: isDark,
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please enter full name'
                  : null,
            ),
            const SizedBox(height: 24),

            // Date of birth
            _buildLabelRow(Icons.calendar_month_outlined, context.tr('date_of_birth'), isDark),
            const SizedBox(height: 8),
            _buildClickableField(
              controller: _date2Controller,
              hintText: context.tr('select_date_hint'),
              isDark: isDark,
              onTap: () => _selectDate(context, false, isDark),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please select date of birth'
                  : null,
            ),
            const SizedBox(height: 24),

            // Time of birth
            _buildLabelRow(Icons.access_time, context.tr('time_of_birth'), isDark),
            const SizedBox(height: 8),
            _buildClickableField(
              controller: _time2Controller,
              hintText: context.tr('select_time_hint'),
              isDark: isDark,
              onTap: () => _selectTime(context, false, isDark),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please select time of birth'
                  : null,
            ),
            const SizedBox(height: 24),

            // Place of birth
            _buildLabelRow(Icons.location_on_outlined, context.tr('place_of_birth'), isDark),
            const SizedBox(height: 8),
            LocationAutocompleteField(
              controller: _place2Controller,
              label: '',
              hint: 'Delhi, India',
              isDark: isDark,
              onLocationSelected: (loc) {
                setState(() {
                  _location2 = loc;
                });
              },
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please enter place of birth'
                  : null,
            ),
            const SizedBox(height: 24),

            // Gender
            _buildLabelRow(null, context.tr('gender'), isDark),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildGenderButton('MALE', context.tr('gender_male'), false, isDark),
                const SizedBox(width: 10),
                _buildGenderButton('FEMALE', context.tr('gender_female'), false, isDark),
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
                      context.tr('back').toUpperCase(),
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
                    text: context.tr('match_kundali_btn'),
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

    final loadingSteps = [
      'Comparing birth charts...',
      'Analyzing Ashtakoota Gunas...',
      'Checking Mangal Dosha match...',
      'Calculating compatibility percentage...',
      'Aligning planetary bonds...',
    ];

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
              loadingSteps[_loadingStep].toUpperCase(),
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
                  value: (_loadingStep + 1) / 5,
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
    final apiProvider = Provider.of<AstrologyApiProvider>(context);
    final matchResult = apiProvider.matchResult;

    final name1 = (matchResult?.profile1Name != null && matchResult!.profile1Name!.isNotEmpty)
        ? matchResult.profile1Name!
        : (_name1Controller.text.isNotEmpty
            ? _name1Controller.text.trim()
            : 'Partner 1');
    final name2 = (matchResult?.profile2Name != null && matchResult!.profile2Name!.isNotEmpty)
        ? matchResult.profile2Name!
        : (_name2Controller.text.isNotEmpty
            ? _name2Controller.text.trim()
            : 'Partner 2');

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
                      context.tr('back'),
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
            context.tr('matching_result'),
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

          // 4. Dynamic Compatibility Analysis (Cosmic Verdict, Strengths, Challenges)
          _buildCompatibilityAnalysisCard(matchResult, isDark),
          const SizedBox(height: 24),

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
                _location1 = null;
                _location2 = null;
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
                  context.tr('match_another'),
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

  Widget _buildCompatibilityAnalysisCard(MatchResultModel? matchResult, bool isDark) {
    if (matchResult == null) return const SizedBox.shrink();

    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);
    final textPrimary = isDark ? Colors.white : AppColors.textPrimaryLight;
    final analysis = matchResult.compatibilityAnalysis;
    final summaryText = analysis?.overallVerdict ??
        'This relationship has been evaluated according to Vedic Ashtakoota 36 Guna principles and planetary harmony.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cosmic Verdict Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xF5FFFFFF),
            borderRadius: BorderRadius.circular(18),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: goldColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'COSMIC VERDICT',
                    style: GoogleFonts.cinzel(
                      color: goldColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      shadows: textShadows,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                summaryText,
                style: GoogleFonts.roboto(
                  color: textPrimary,
                  fontSize: 13,
                  height: 1.5,
                  shadows: textShadows,
                ),
              ),
            ],
          ),
        ),

        // Cosmic Strengths
        if (analysis?.strengths != null && analysis!.strengths!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.green.withValues(alpha: 0.08)
                  : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.greenAccent.withValues(alpha: 0.35) : const Color(0xFF81C784),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: isDark ? Colors.greenAccent : const Color(0xFF2E7D32),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'KEY HARMONIES & STRENGTHS',
                      style: GoogleFonts.cinzel(
                        color: isDark ? Colors.greenAccent : const Color(0xFF2E7D32),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  analysis.strengths!,
                  style: GoogleFonts.roboto(
                    color: textPrimary,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Cosmic Challenges
        if (analysis?.challenges != null && analysis!.challenges!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.orange.withValues(alpha: 0.08)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.orangeAccent.withValues(alpha: 0.35) : const Color(0xFFFFB74D),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: isDark ? Colors.orangeAccent : const Color(0xFFE65100),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AREAS FOR GROWTH & ATTENTION',
                      style: GoogleFonts.cinzel(
                        color: isDark ? Colors.orangeAccent : const Color(0xFFE65100),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  analysis.challenges!,
                  style: GoogleFonts.roboto(
                    color: textPrimary,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildScoreVisualCard(String name1, String name2, bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);
    final textPrimary = isDark ? Colors.white : AppColors.textPrimaryLight;
    final textSecondary = isDark ? Colors.white70 : AppColors.textSecondaryLight;

    final apiProvider = Provider.of<AstrologyApiProvider>(context);
    final matchResult = apiProvider.matchResult;
    final totalScore = matchResult?.totalScore ?? 0.0;
    final maxScore = matchResult?.maxScore ?? 36.0;
    final percentage = matchResult?.percentage ?? (maxScore > 0 ? (totalScore / maxScore) * 100 : 0.0);
    final verdict = matchResult?.verdict ?? (totalScore >= 18.0 ? 'EXCELLENT MATCH' : 'AVERAGE MATCH');
    final isGood = totalScore >= 18.0;

    final moon1 = matchResult?.profile1MoonSign;
    final moon2 = matchResult?.profile2MoonSign;

    final totalScoreDisplay = totalScore % 1 == 0 ? '${totalScore.toInt()}' : totalScore.toStringAsFixed(1);
    final maxScoreDisplay = maxScore % 1 == 0 ? '${maxScore.toInt()}' : maxScore.toStringAsFixed(1);

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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      moon1 != null && moon1.isNotEmpty
                          ? 'Moon: $moon1'
                          : (_gender1 == 'MALE' ? context.tr('gender_male') : context.tr('gender_female')),
                      style: GoogleFonts.roboto(
                        color: textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        shadows: textShadows,
                      ),
                      textAlign: TextAlign.center,
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
                          value: (maxScore > 0 ? totalScore / maxScore : 0.0).clamp(0.0, 1.0),
                          strokeWidth: 6,
                          backgroundColor: isDark ? Colors.white12 : const Color(0x20D4A827),
                          color: isGood
                              ? (isDark ? const Color(0xFF00FFCC) : const Color(0xFF00BFA5))
                              : (isDark ? Colors.orangeAccent : const Color(0xFFE65100)),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            totalScoreDisplay,
                            style: GoogleFonts.roboto(
                              color: textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: textShadows,
                            ),
                          ),
                          Text(
                            percentage > 0
                                ? '${percentage.toStringAsFixed(1)}%'
                                : 'out of $maxScoreDisplay',
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      moon2 != null && moon2.isNotEmpty
                          ? 'Moon: $moon2'
                          : (_gender2 == 'FEMALE' ? context.tr('gender_female') : context.tr('gender_male')),
                      style: GoogleFonts.roboto(
                        color: textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        shadows: textShadows,
                      ),
                      textAlign: TextAlign.center,
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
              color: isGood
                  ? Colors.green.withValues(alpha: isDark ? 0.12 : 0.15)
                  : Colors.orange.withValues(alpha: isDark ? 0.12 : 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isGood
                    ? Colors.green.withValues(alpha: 0.4)
                    : Colors.orange.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Text(
              verdict,
              style: GoogleFonts.cinzel(
                color: isGood
                    ? (isDark ? Colors.greenAccent : const Color(0xFF2E7D32))
                    : (isDark ? Colors.orangeAccent : const Color(0xFFE65100)),
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

    final apiProvider = Provider.of<AstrologyApiProvider>(context);
    final matchResult = apiProvider.matchResult;
    final hasCustomGunas = matchResult != null && matchResult.gunas.isNotEmpty;
    final totalScore = matchResult?.totalScore ?? 0.0;
    final maxScore = matchResult?.maxScore ?? 36.0;

    final totalScoreDisplay = totalScore % 1 == 0 ? '${totalScore.toInt()}' : totalScore.toStringAsFixed(1);
    final maxScoreDisplay = maxScore % 1 == 0 ? '${maxScore.toInt()}' : maxScore.toStringAsFixed(1);

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
            context.tr('guna_matching_title'),
            style: GoogleFonts.cinzel(
              color: goldColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              shadows: textShadows,
            ),
          ),
          const SizedBox(height: 16),
          // Dynamic Guna table rows from API
          if (hasCustomGunas)
            ...matchResult.gunas.map((g) => _buildGunaRow(
                  g.name,
                  g.description ?? '',
                  g.maxScore,
                  g.score,
                  isDark,
                ))
          else ...[
            _buildGunaRow('Varna', 'Spiritual compatibility', 1, 0, isDark),
            _buildGunaRow('Vasya', 'Power & dominance', 2, 0, isDark),
            _buildGunaRow('Tara', 'Destiny & fortune', 3, 0, isDark),
            _buildGunaRow('Yoni', 'Nature & instinct', 4, 0, isDark),
            _buildGunaRow('Graha Maitri', 'Planet friendship', 5, 0, isDark),
            _buildGunaRow('Gana', 'Temperament match', 6, 0, isDark),
            _buildGunaRow('Bhakoot', 'Love & prosperity', 7, 0, isDark),
            _buildGunaRow('Nadi', 'Health & progeny', 8, 0, isDark),
          ],

          Divider(
            color: isDark ? AppColors.borderDark : const Color(0x20D4A827),
            height: 24,
            thickness: 1.2,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('total_score'),
                style: GoogleFonts.cinzel(
                  color: goldColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  shadows: textShadows,
                ),
              ),
              Text(
                '$totalScoreDisplay/$maxScoreDisplay',
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

  Widget _buildGunaRow(String gunaName, String desc, num max, num obtained, bool isDark) {
    Color barColor = isDark ? const Color(0xFF00FFCC) : const Color(0xFF00BFA5);
    if (obtained < max / 2) {
      barColor = AppColors.goldOrange;
    } else if (obtained < max) {
      barColor = AppColors.getGold(isDark);
    }

    final textShadows = AppColors.getTextShadows(isDark);
    final textPrimary = isDark ? Colors.white : AppColors.textPrimaryLight;
    final textDesc = isDark ? Colors.white54 : AppColors.textMutedLight;

    final maxStr = max % 1 == 0 ? '${max.toInt()}' : max.toStringAsFixed(1);
    final obtainedStr = obtained % 1 == 0 ? '${obtained.toInt()}' : obtained.toStringAsFixed(1);

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
                if (desc.isNotEmpty)
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
            width: 28,
            child: Text(
              maxStr,
              style: GoogleFonts.roboto(
                color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                fontSize: 12,
                shadows: textShadows,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              obtainedStr,
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
                  widthFactor: (max > 0 ? (obtained / max) : 0.0).clamp(0.0, 1.0),
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
    final apiProvider = Provider.of<AstrologyApiProvider>(context);
    final matchResult = apiProvider.matchResult;
    final isCompatible = matchResult?.isMangalCompatible ?? true;
    final desc = matchResult?.mangalDoshaDescription ??
        (isCompatible
            ? context.tr('mangal_compatible_desc')
            : 'Mangal Dosha present in chart.');
    final title = isCompatible
        ? context.tr('mangal_dosha_compatible')
        : 'Mangal Dosha Detected';
    final accentColor = isCompatible
        ? (isDark ? Colors.greenAccent : const Color(0xFF2E7D32))
        : (isDark ? Colors.orangeAccent : const Color(0xFFE65100));
    final iconData = isCompatible ? Icons.check_circle_outline : Icons.info_outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xF5FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
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
            iconData,
            color: accentColor,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cinzel(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    shadows: AppColors.getTextShadows(isDark),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
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
            context.tr('kundali_matching'),
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
            context.tr('matching_sub'),
            style: GoogleFonts.roboto(
              color: textSubtitle,
              fontSize: 11,
              shadows: textShadows,
            ),
            textAlign: TextAlign.center,
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
          Expanded(child: _buildStepCapsule(1, context.tr('person_1'), activeStep >= 1, isDark)),
          Expanded(child: _buildStepCapsule(2, context.tr('person_2'), activeStep >= 2, isDark)),
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

  Widget _buildGenderButton(String genderCode, String genderLabel, bool isPerson1, bool isDark) {
    final isSelected = isPerson1 ? _gender1 == genderCode : _gender2 == genderCode;
    final goldColor = AppColors.getGold(isDark);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isPerson1) {
              _gender1 = genderCode;
            } else {
              _gender2 = genderCode;
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
              genderLabel,
              style: GoogleFonts.cinzel(
                color: isSelected
                    ? Colors.black
                    : (isDark ? Colors.white : AppColors.textPrimaryLight),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 12,
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
