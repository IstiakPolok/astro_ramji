import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../providers/theme_provider.dart';

class KundaliFormScreen extends StatefulWidget {
  const KundaliFormScreen({super.key});

  @override
  State<KundaliFormScreen> createState() => _KundaliFormScreenState();
}

class _KundaliFormScreenState extends State<KundaliFormScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  // Form Fields
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedGender = 'MALE';
  String _selectedAyanamsa = 'LAHIRI (CHITRAPAKSHA)';
  int _activeTab = 0;

  // Interaction / Loading / Results State
  bool _isCalculating = false;
  bool _showResult = false;
  bool _showDetailedReport = false;
  int _loadingStep = 0;
  late AnimationController _rotationController;

  final List<String> _loadingSteps = [
    'Locating birth coordinates...',
    'Retrieving planetary ephemeris...',
    'Calculating Lagna (Ascendant)...',
    'Structuring Kundali houses...',
    'Generating custom chart...',
  ];

  final List<String> _ayanamsas = [
    'LAHIRI (CHITRAPAKSHA)',
    'RAMAN',
    'KRISHNAMURTI (KP)',
    'SAYANA',
    'FAGAN-BRADLEY',
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

    // Rotation animation for spinner
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _rotationController.dispose();
    _nameController.dispose();
    _placeController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // --- Pickers ---
  Future<void> _selectDate(BuildContext context, bool isDark) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1998, 1, 24),
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

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        final List<String> months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        _dateController.text =
            "${picked.day} ${months[picked.month - 1]} ${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isDark) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 10, minute: 15),
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

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  // --- Ayanamsa Dialog Selector ---
  void _showAyanamsaPicker(bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textColor = AppColors.getTextPrimary(isDark);

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
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SELECT AYANAMSA',
                style: GoogleFonts.cinzel(
                  color: goldColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _ayanamsas.length,
                  itemBuilder: (context, index) {
                    final option = _ayanamsas[index];
                    final isSelected = option == _selectedAyanamsa;
                    return ListTile(
                      title: Text(
                        option,
                        style: GoogleFonts.roboto(
                          color: isSelected ? goldColor : textColor,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: goldColor,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedAyanamsa = option;
                        });
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

  // --- Loading Animation Controller ---
  void _startCalculation() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
      _loadingStep = 0;
    });
    _rotationController.repeat();

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
        _rotationController.stop();
        setState(() {
          _isCalculating = false;
          _showResult = true;
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
            // Celestial Background
            // In Light Mode: LIGHT2.png
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
                      AppAssets.bgLight2,
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

            // Main Content
            SafeArea(
              bottom: false,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _isCalculating
                    ? _buildLoadingScreen(isDark)
                    : (_showDetailedReport
                        ? _buildDetailedReportScreen(isDark)
                        : (_showResult
                            ? _buildResultScreen(isDark)
                            : _buildFormScreen(isDark))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SCREEN 1: THE INPUT FORM
  // ==========================================
  Widget _buildFormScreen(bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);
    final subtitleColor = isDark ? Colors.white : AppColors.textSecondaryLight;

    return SingleChildScrollView(
      key: const ValueKey('form_screen'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Header Title
            Center(
              child: Column(
                children: [
                  Text(
                    'BIRTH DETAILS',
                    style: GoogleFonts.cinzel(
                      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      shadows: textShadows,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Accurate information ensures precise Kundali results',
                    style: GoogleFonts.roboto(
                      color: subtitleColor,
                      fontSize: 12,
                      letterSpacing: 0.2,
                      shadows: textShadows,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // 1. FULL NAME
            _buildLabelRow(Icons.person_outline, 'FULL NAME', isDark),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hintText: 'Aarav Sharma',
              isDark: isDark,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 2. GENDER
            _buildLabelRow(null, 'GENDER', isDark),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildGenderButton('MALE', isDark),
                const SizedBox(width: 10),
                _buildGenderButton('FEMALE', isDark),
                const SizedBox(width: 10),
                _buildGenderButton('OTHER', isDark),
              ],
            ),
            const SizedBox(height: 24),

            // 3. DATE OF BIRTH
            _buildLabelRow(Icons.calendar_month_outlined, 'DATE OF BIRTH', isDark),
            const SizedBox(height: 8),
            _buildClickableField(
              controller: _dateController,
              hintText: 'Select date of birth',
              isDark: isDark,
              onTap: () => _selectDate(context, isDark),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please select date of birth';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 4. TIME OF BIRTH
            _buildLabelRow(Icons.access_time, 'TIME OF BIRTH', isDark),
            const SizedBox(height: 8),
            _buildClickableField(
              controller: _timeController,
              hintText: 'Select time of birth',
              isDark: isDark,
              onTap: () => _selectTime(context, isDark),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please select time of birth';
                }
                return null;
              },
            ),
            const SizedBox(height: 4),
            Text(
              'Accurate birth time gives more precise results',
              style: GoogleFonts.roboto(
                color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                fontSize: 11,
                shadows: textShadows,
              ),
            ),
            const SizedBox(height: 24),

            // 5. PLACE OF BIRTH
            _buildLabelRow(Icons.location_on_outlined, 'PLACE OF BIRTH', isDark),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _placeController,
              hintText: 'Mumbai, Maharashtra',
              isDark: isDark,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter place of birth';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            // 6. AYANAMSA (LAVENDER CARD)
            GestureDetector(
              onTap: () => _showAyanamsaPicker(isDark),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF16112C).withValues(alpha: 0.6)
                      : const Color(0xE8FFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? AppColors.accentPurple.withValues(alpha: 0.3)
                        : goldColor.withValues(alpha: 0.4),
                    width: 1.2,
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
                      'AYANAMSA: $_selectedAyanamsa',
                      style: GoogleFonts.cinzel(
                        color: isDark ? AppColors.accentPurple : goldColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        shadows: textShadows,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Standard Vedic calculation method used by most Indian astrologers',
                      style: GoogleFonts.roboto(
                        color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                        fontSize: 10,
                        shadows: textShadows,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),

            // 7. GENERATE BUTTON
            GestureDetector(
              onTap: _startCalculation,
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
                    'GENERATE KUNDALI ✨',
                    style: GoogleFonts.cinzel(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SCREEN 2: CELESTIAL LOADING
  // ==========================================
  Widget _buildLoadingScreen(bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Center(
      key: const ValueKey('loading_screen'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Rotating Celestial Spinner
            RotationTransition(
              turns: _rotationController,
              child: SizedBox(
                width: 180,
                height: 180,
                child: Image.asset(
                  AppAssets.rashiChakra,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: goldColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_awesome,
                          color: goldColor,
                          size: 64,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Loading text step
            Text(
              _loadingSteps[_loadingStep].toUpperCase(),
              style: GoogleFonts.cinzel(
                color: goldColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Subtitle
            Text(
              'Aligning celestial bodies and planetary configurations for ${_nameController.text}',
              style: GoogleFonts.roboto(
                color: textColor,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Progress bar
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
  // SCREEN 3: CHART RESULTS SCREEN
  // ==========================================
  Widget _buildResultScreen(bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);

    return SingleChildScrollView(
      key: const ValueKey('result_screen'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Back button
          GestureDetector(
            onTap: () {
              setState(() {
                _showResult = false;
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
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Header: User details
          Text(
            _nameController.text.toUpperCase(),
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
            '${_dateController.text} • ${_timeController.text}',
            style: GoogleFonts.roboto(
              color: isDark ? Colors.white : AppColors.textSecondaryLight,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              shadows: textShadows,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _placeController.text,
            style: GoogleFonts.roboto(
              color: isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.textMutedLight,
              fontSize: 13,
              shadows: textShadows,
            ),
          ),
          const SizedBox(height: 24),

          // 3. Tab Bar (CHART, PLANETS, VIMSHOTTARI)
          _buildTabBar(isDark),
          const SizedBox(height: 24),

          // 4. Tab Content Switcher
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _activeTab == 0
                ? _buildChartTab(isDark)
                : (_activeTab == 1
                    ? _buildPlanetsTab(isDark)
                    : _buildVimshottariTab(isDark)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark.withValues(alpha: 0.5) : const Color(0xE8FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: isDark ? null : Border.all(color: const Color(0x30D4A827), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(0, 'CHART', isDark),
          _buildTabItem(1, 'PLANETS', isDark),
          _buildTabItem(2, 'VIMSHOTTARI', isDark),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, bool isDark) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = index;
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
                fontSize: 12,
                letterSpacing: 0.8,
                shadows: isSelected ? null : AppColors.getTextShadows(isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- CHART TAB ---
  Widget _buildChartTab(bool isDark) {
    final goldColor = AppColors.getGold(isDark);

    return Column(
      key: const ValueKey('chart_tab'),
      children: [
        // Sign Info Row (Lagna, Moon, Sun)
        Row(
          children: [
            _buildSignInfoCard('LAGNA', 'Pisces', '♓', Colors.purpleAccent, isDark),
            const SizedBox(width: 8),
            _buildSignInfoCard('MOON', 'Scorpio', '♏', Colors.pinkAccent, isDark),
            const SizedBox(width: 8),
            _buildSignInfoCard('SUN', 'Aquarius', '♒', Colors.deepPurpleAccent, isDark),
          ],
        ),
        const SizedBox(height: 20),

        // Custom painted North Indian chart card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0C071D).withValues(alpha: 0.85)
                : const Color(0xF7FFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: goldColor.withValues(alpha: isDark ? 0.25 : 0.45),
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
            children: [
              AspectRatio(
                aspectRatio: 1.05,
                child: CustomPaint(
                  painter: KundaliChartPainter(isDark: isDark),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NORTH INDIAN STYLE',
                    style: GoogleFonts.cinzel(
                      color: goldColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$_selectedAyanamsa Ayanamsa',
                      style: GoogleFonts.roboto(
                        color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                        fontSize: 11,
                        shadows: AppColors.getTextShadows(isDark),
                      ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Planet Positions Card
        _buildPlanetPositionsCard(isDark: isDark),
        const SizedBox(height: 24),

        // View Detailed Report Button
        _buildViewReportButton(isDark),
      ],
    );
  }

  // --- PLANETS TAB ---
  Widget _buildPlanetsTab(bool isDark) {
    return Column(
      key: const ValueKey('planets_tab'),
      children: [
        _buildPlanetPositionsCard(isExpanded: true, isDark: isDark),
        const SizedBox(height: 24),
        _buildViewReportButton(isDark),
      ],
    );
  }

  // --- VIMSHOTTARI TAB ---
  Widget _buildVimshottariTab(bool isDark) {
    final goldColor = AppColors.getGold(isDark);

    return Column(
      key: const ValueKey('vimshottari_tab'),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0C071D).withValues(alpha: 0.8)
                : const Color(0xF7FFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: goldColor.withValues(alpha: isDark ? 0.2 : 0.4),
              width: 1.2,
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
              Text(
                'VIMSHOTTARI MAHADASHAS',
                style: GoogleFonts.cinzel(
                  color: goldColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 20),
              _buildTimelineItem(
                'Jupiter Dasha',
                '16 Years',
                '1990 - 2006',
                isDark,
                isPast: true,
              ),
              _buildTimelineItem(
                'Saturn Dasha',
                '19 Years',
                '2006 - 2025',
                isDark,
                isPast: true,
              ),
              _buildTimelineItem(
                'Mercury Dasha',
                '17 Years',
                '2025 - 2042',
                isDark,
                isCurrent: true,
              ),
              _buildTimelineItem('Ketu Dasha', '7 Years', '2042 - 2049', isDark),
              _buildTimelineItem(
                'Venus Dasha',
                '20 Years',
                '2049 - 2069',
                isDark,
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildViewReportButton(isDark),
      ],
    );
  }

  // --- Helper Widgets ---
  Widget _buildSignInfoCard(
    String label,
    String sign,
    String symbol,
    Color symbolColor,
    bool isDark,
  ) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0x15FFFFFF) : const Color(0xE8FFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: goldColor.withValues(alpha: isDark ? 0.25 : 0.4),
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
          children: [
            Text(
              label,
              style: GoogleFonts.cinzel(
                color: goldColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                shadows: textShadows,
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.roboto(
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  shadows: textShadows,
                ),
                children: [
                  TextSpan(text: '$sign '),
                  TextSpan(
                    text: symbol,
                    style: TextStyle(
                      color: symbolColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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

  Widget _buildPlanetPositionsCard({bool isExpanded = false, required bool isDark}) {
    final goldColor = AppColors.getGold(isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C071D).withValues(alpha: 0.85) : const Color(0xF7FFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: goldColor.withValues(alpha: isDark ? 0.2 : 0.4),
          width: 1.2,
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
          Text(
            'PLANET POSITIONS',
            style: GoogleFonts.cinzel(
              color: goldColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 20),

          if (!isExpanded) ...[
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
              children: [
                _buildPlanetItem('☉', 'Su', 'H12', isDark),
                _buildPlanetItem('☽', 'Mo', 'H9', isDark),
                _buildPlanetItem('♂', 'Ma', 'H10', isDark),
                _buildPlanetItem('☿', 'Me', 'H11', isDark, isRetrograde: true),
                _buildPlanetItem('♃', 'Ju', 'H4', isDark),
                _buildPlanetItem('♀', 'Ve', 'H11', isDark),
                _buildPlanetItem('♄', 'Sa', 'H10', isDark),
                _buildPlanetItem('☊', 'Ra', 'H7', isDark, isRetrograde: true),
                _buildPlanetItem('☋', 'Ke', 'H1', isDark, isRetrograde: true),
              ],
            ),
          ] else ...[
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPlanetDetailRow('☉', 'Sun', 'Pisces', 'H12', '29° 12\'', 'Revati', isDark),
                _buildPlanetDetailRow('☽', 'Moon', 'Scorpio', 'H9', '14° 02\'', 'Anuradha', isDark),
                _buildPlanetDetailRow('♂', 'Mars', 'Capricorn', 'H10', '10° 45\'', 'Shravana', isDark),
                _buildPlanetDetailRow('☿', 'Mercury (R)', 'Aquarius', 'H11', '18° 10\'', 'Shatabhisha', isDark, isRetrograde: true),
                _buildPlanetDetailRow('♃', 'Jupiter', 'Cancer', 'H4', '04° 15\'', 'Pushya', isDark),
                _buildPlanetDetailRow('♀', 'Venus', 'Aquarius', 'H11', '12° 30\'', 'Shatabhisha', isDark),
                _buildPlanetDetailRow('♄', 'Saturn', 'Capricorn', 'H10', '22° 40\'', 'Dhanishta', isDark),
                _buildPlanetDetailRow('☊', 'Rahu (R)', 'Libra', 'H7', '07° 50\'', 'Swati', isDark, isRetrograde: true),
                _buildPlanetDetailRow('☋', 'Ketu (R)', 'Aries', 'H1', '07° 50\'', 'Ashwini', isDark, isRetrograde: true),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanetItem(
    String symbol,
    String name,
    String house,
    bool isDark, {
    bool isRetrograde = false,
  }) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          symbol,
          style: GoogleFonts.roboto(
            color: goldColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: textShadows,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                style: GoogleFonts.roboto(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  shadows: textShadows,
                ),
                children: [
                  TextSpan(text: name),
                  if (isRetrograde)
                    const TextSpan(
                      text: ' R',
                      style: TextStyle(
                        color: AppColors.goldOrange,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              house,
              style: GoogleFonts.roboto(
                color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                fontSize: 10,
                shadows: textShadows,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanetDetailRow(
    String symbol,
    String name,
    String sign,
    String house,
    String degree,
    String nakshatra,
    bool isDark, {
    bool isRetrograde = false,
  }) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final textSecondary = isDark ? Colors.white70 : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.borderDark.withValues(alpha: 0.3)
                : const Color(0x20D4A827),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              symbol,
              style: GoogleFonts.roboto(
                color: goldColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: textShadows,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: GoogleFonts.roboto(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                shadows: textShadows,
              ),
            ),
          ),
          Expanded(
            child: Text(
              house,
              style: GoogleFonts.roboto(
                color: goldColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                shadows: textShadows,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              sign,
              style: GoogleFonts.roboto(
                color: textSecondary,
                fontSize: 12,
                shadows: textShadows,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  degree,
                  style: GoogleFonts.roboto(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    shadows: textShadows,
                  ),
                ),
                Text(
                  nakshatra,
                  style: GoogleFonts.roboto(
                    color: isDark ? Colors.white60 : AppColors.textMutedLight,
                    fontSize: 10,
                    shadows: textShadows,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String duration,
    String years,
    bool isDark, {
    bool isPast = false,
    bool isCurrent = false,
    bool isLast = false,
  }) {
    Color dotColor = isDark ? Colors.white38 : Colors.black26;
    Color textColor = isDark ? Colors.white70 : AppColors.textSecondaryLight;
    if (isCurrent) {
      dotColor = AppColors.goldOrange;
      textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    } else if (isPast) {
      dotColor = AppColors.getGold(isDark).withValues(alpha: 0.8);
      textColor = isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.textPrimaryLight.withValues(alpha: 0.8);
    }

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.goldOrange.withValues(alpha: 0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDark
                        ? AppColors.borderDark.withValues(alpha: 0.5)
                        : const Color(0x30D4A827),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.roboto(
                          color: textColor,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 13,
                          shadows: AppColors.getTextShadows(isDark),
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldOrange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.goldOrange.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'CURRENT',
                            style: TextStyle(
                              color: AppColors.goldOrange,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$duration • $years',
                    style: GoogleFonts.roboto(
                      color: isDark ? Colors.white60 : AppColors.textMutedLight,
                      fontSize: 11,
                      shadows: AppColors.getTextShadows(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewReportButton(bool isDark) {
    final goldColor = AppColors.getGold(isDark);

    return GestureDetector(
      onTap: () {
        setState(() {
          _showDetailedReport = true;
        });
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1B30) : const Color(0xFFFAF6ED),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'VIEW DETAILED REPORT',
                style: GoogleFonts.cinzel(
                  color: goldColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: goldColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SCREEN 4: DETAILED ASTROLOGY REPORT
  // ==========================================
  Widget _buildDetailedReportScreen(bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textShadows = AppColors.getTextShadows(isDark);

    return SingleChildScrollView(
      key: const ValueKey('detailed_report'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Back button to result
          GestureDetector(
            onTap: () {
              setState(() {
                _showDetailedReport = false;
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
                  'Chart Overview',
                  style: GoogleFonts.roboto(
                    color: goldColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Report Header
          Text(
            'DETAILED KUNDALI REPORT',
            style: GoogleFonts.cinzel(
              color: textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              shadows: textShadows,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Comprehensive Vedic analysis for ${_nameController.text}',
            style: GoogleFonts.roboto(
              color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
              fontSize: 12,
              shadows: textShadows,
            ),
          ),
          const SizedBox(height: 24),

          // 3. LAGNA & PERSONALITY SUMMARY CARD
          _buildReportCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardLabel('ASCENDANT & CORE NATURE', isDark),
                const SizedBox(height: 12),
                Text(
                  'Lagna: Pisces (Meen) · Ruler: Jupiter (Guru)',
                  style: GoogleFonts.roboto(
                    color: goldColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    shadows: textShadows,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your Lagna in Pisces gives you an empathetic, deeply spiritual, and intuitive disposition. You possess strong artistic sensitivities and emotional depth, with Jupiter positioned in the auspicious 4th house giving maternal blessings and property fortune.',
                  style: GoogleFonts.roboto(
                    color: isDark ? Colors.white.withValues(alpha: 0.85) : AppColors.textPrimaryLight,
                    fontSize: 12,
                    height: 1.5,
                    shadows: textShadows,
                  ),
                ),
              ],
            ),
          ),

          // 4. PLANETARY STRENGTHS (SHADBALA) CARD
          _buildReportCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardLabel('PLANETARY STRENGTHS (SHADBALA)', isDark),
                const SizedBox(height: 16),
                _buildShadbalaRow('♃ Jupiter (Guru)', 1.45, 'Exalted / Strong', Colors.green, isDark),
                _buildShadbalaRow('☉ Sun (Surya)', 1.22, 'Strong', Colors.green, isDark),
                _buildShadbalaRow('♂ Mars (Mangal)', 1.15, 'Average', Colors.amber, isDark),
                _buildShadbalaRow('☽ Moon (Chandra)', 0.95, 'Moderate', Colors.orange, isDark),
                _buildShadbalaRow('☿ Mercury (Budh)', 0.78, 'Debilitated / Weak', Colors.redAccent, isDark),
              ],
            ),
          ),

          // 5. DOSHA ANALYSIS CARD
          _buildReportCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardLabel('DOSHA & YOGA ANALYSIS', isDark),
                const SizedBox(height: 14),
                _buildDoshaItem('Mangal Dosha', 'NO DOSHA', 'Mars is well-aspected in the 10th house, nullifying harmful afflicting energy.', Colors.green, isDark),
                const SizedBox(height: 10),
                _buildDoshaItem('Kaal Sarp Dosha', 'PARTIAL (ANANT)', 'Planets are semi-hemmed between Rahu and Ketu. Regular worship of Lord Shiva is beneficial.', Colors.amber, isDark),
                const SizedBox(height: 10),
                _buildDoshaItem('Gaja Kesari Yoga', 'PRESENT ✨', 'Jupiter in quadrant with Moon creates supreme intellect, fame, and royal recognition.', Colors.green, isDark),
              ],
            ),
          ),

          // 6. SARVASHTAKAVARGA CARD
          _buildReportCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardLabel('SARVASHTAKAVARGA', isDark),
                const SizedBox(height: 16),
                _buildSarvashtakavargaRow('☉', 'Sun', 34, isDark),
                _buildSarvashtakavargaRow('☽', 'Moon', 36, isDark),
                _buildSarvashtakavargaRow('♂', 'Mars', 22, isDark),
                _buildSarvashtakavargaRow('☿', 'Mercury', 27, isDark),
                _buildSarvashtakavargaRow('♃', 'Jupiter', 39, isDark),
                _buildSarvashtakavargaRow('♀', 'Venus', 31, isDark),
                _buildSarvashtakavargaRow('♄', 'Saturn', 24, isDark),
              ],
            ),
          ),

          // 7. RECOMMENDED REMEDIES CARD
          _buildReportCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardLabel('RECOMMENDED REMEDIES', isDark),
                const SizedBox(height: 16),
                _buildRemedyRow(Icons.diamond_outlined, Colors.blueAccent, 'Yellow Sapphire (Pukhraj)', 'Strengthen Jupiter • Ring finger, gold setting', isDark),
                const SizedBox(height: 16),
                _buildRemedyRow(Icons.fireplace_outlined, Colors.amber, 'Thursday Puja', 'Offer bananas & sweets to Lord Vishnu', isDark),
                const SizedBox(height: 16),
                _buildRemedyRow(Icons.grain_outlined, Colors.redAccent, 'Jupiter Mantra', 'Om Gram Greem Graum Sah Guruve Namah - 108x', isDark),
                const SizedBox(height: 16),
                _buildRemedyRow(Icons.water_drop_outlined, Colors.lightBlueAccent, 'Sun Offering', 'Offer water to the Sun every morning facing east', isDark),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 8. DOWNLOAD BUTTON
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: isDark ? AppColors.cardDark : AppColors.spaceLight,
                  content: Text(
                    'Downloading report in background...',
                    style: GoogleFonts.roboto(color: goldColor, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download, color: Colors.black, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'DOWNLOAD PDF REPORT',
                      style: GoogleFonts.cinzel(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildReportCard({required Widget child, required bool isDark}) {
    final goldColor = AppColors.getGold(isDark);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xF2FFFFFF),
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
      child: child,
    );
  }

  Widget _buildCardLabel(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.cinzel(
        color: AppColors.getGold(isDark),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
        shadows: AppColors.getTextShadows(isDark),
      ),
    );
  }

  Widget _buildShadbalaRow(
    String planet,
    double rupa,
    String status,
    Color statusColor,
    bool isDark,
  ) {
    final textShadows = AppColors.getTextShadows(isDark);
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              planet,
              style: GoogleFonts.roboto(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                shadows: textShadows,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${rupa.toStringAsFixed(2)} Rupa',
              style: GoogleFonts.roboto(
                color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                fontSize: 11,
                shadows: textShadows,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoshaItem(
    String title,
    String status,
    String description,
    Color badgeColor,
    bool isDark,
  ) {
    final textShadows = AppColors.getTextShadows(isDark);
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFFAF7F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0x30D4A827),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.roboto(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  shadows: textShadows,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: badgeColor.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.roboto(
              color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
              fontSize: 11,
              shadows: textShadows,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSarvashtakavargaRow(String symbol, String name, int score, bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            symbol,
            style: GoogleFonts.roboto(
              color: goldColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              shadows: textShadows,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(
              name,
              style: GoogleFonts.roboto(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                shadows: textShadows,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 8,
                color: isDark ? Colors.white12 : const Color(0x20D4A827),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: score / 50.0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.buttonGradient,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$score',
            style: GoogleFonts.roboto(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: textShadows,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemedyRow(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle,
    bool isDark,
  ) {
    final textShadows = AppColors.getTextShadows(isDark);
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withValues(alpha: 0.12),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Center(child: Icon(icon, color: iconColor, size: 20)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.roboto(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  shadows: textShadows,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.roboto(
                  color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                  fontSize: 11,
                  shadows: textShadows,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Helper Widgets for Screen elements ---
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

  Widget _buildGenderButton(String gender, bool isDark) {
    final isSelected = _selectedGender == gender;
    final goldColor = AppColors.getGold(isDark);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = gender;
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
}

// ==========================================
// CUSTOM PAINTER FOR NORTH INDIAN KUNDALI
// ==========================================
class KundaliChartPainter extends CustomPainter {
  final bool isDark;

  KundaliChartPainter({this.isDark = true});

  @override
  void paint(Canvas canvas, Size size) {
    final goldStrokeColor = isDark
        ? AppColors.goldPrimary.withValues(alpha: 0.7)
        : AppColors.goldPrimaryDark;

    final paint = Paint()
      ..color = goldStrokeColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // 1. Draw outer square border
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);

    // 2. Draw diagonals
    canvas.drawLine(const Offset(0, 0), Offset(w, h), paint);
    canvas.drawLine(Offset(0, h), Offset(w, 0), paint);

    // 3. Draw inner rotated square (connecting midpoints)
    canvas.drawLine(Offset(w / 2, 0), Offset(w, h / 2), paint);
    canvas.drawLine(Offset(w, h / 2), Offset(w / 2, h), paint);
    canvas.drawLine(Offset(w / 2, h), Offset(0, h / 2), paint);
    canvas.drawLine(Offset(0, h / 2), Offset(w / 2, 0), paint);

    // 4. Draw central circle to shield lines and show Lagna details
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF0C071D) : const Color(0xFFFFFDF8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h / 2), 32, bgPaint);

    final borderPaint = Paint()
      ..color = isDark
          ? AppColors.goldPrimary.withValues(alpha: 0.35)
          : AppColors.goldPrimaryDark.withValues(alpha: 0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(w / 2, h / 2), 32, borderPaint);

    final textShadows = AppColors.getTextShadows(isDark);

    // Paint Lagna center text
    _drawRichText(
      canvas,
      TextSpan(
        text: 'LAGNA',
        style: GoogleFonts.cinzel(
          color: goldStrokeColor,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          shadows: textShadows,
        ),
      ),
      Offset(w / 2, h / 2 - 8),
    );

    _drawRichText(
      canvas,
      TextSpan(
        style: GoogleFonts.roboto(
          color: goldStrokeColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          shadows: textShadows,
        ),
        children: const [
          TextSpan(
            text: '♓ ',
            style: TextStyle(color: Colors.purpleAccent),
          ),
          TextSpan(text: 'MEEN'),
        ],
      ),
      Offset(w / 2, h / 2 + 8),
    );

    // 5. Draw House numbers and Planets
    final numStyle = TextStyle(
      color: isDark
          ? AppColors.goldPrimary.withValues(alpha: 0.7)
          : AppColors.goldPrimaryDark,
      fontSize: 10,
      fontWeight: FontWeight.w600,
      shadows: textShadows,
    );
    final planetStyle = TextStyle(
      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      shadows: textShadows,
    );

    // House 1 (top center)
    _drawRichText(
      canvas,
      TextSpan(text: '1', style: numStyle),
      Offset(w / 2, h * 0.32),
    );
    _drawRichText(
      canvas,
      TextSpan(text: 'Ke', style: planetStyle),
      Offset(w / 2, h * 0.22),
    );

    // House 2 (top right)
    _drawRichText(
      canvas,
      TextSpan(text: '2', style: numStyle),
      Offset(w * 0.65, h * 0.16),
    );

    // House 3 (right top)
    _drawRichText(
      canvas,
      TextSpan(text: '3', style: numStyle),
      Offset(w * 0.82, h * 0.33),
    );

    // House 4 (right center)
    _drawRichText(
      canvas,
      TextSpan(text: '4', style: numStyle),
      Offset(w * 0.70, h * 0.47),
    );
    _drawRichText(
      canvas,
      TextSpan(text: 'Ju', style: planetStyle),
      Offset(w * 0.70, h * 0.53),
    );

    // House 5 (right bottom)
    _drawRichText(
      canvas,
      TextSpan(text: '5', style: numStyle),
      Offset(w * 0.82, h * 0.67),
    );

    // House 6 (bottom right)
    _drawRichText(
      canvas,
      TextSpan(text: '6', style: numStyle),
      Offset(w * 0.65, h * 0.84),
    );

    // House 7 (bottom center)
    _drawRichText(
      canvas,
      TextSpan(text: '7', style: numStyle),
      Offset(w / 2, h * 0.68),
    );
    _drawRichText(
      canvas,
      TextSpan(text: 'Ra', style: planetStyle),
      Offset(w / 2, h * 0.78),
    );

    // House 8 (bottom left)
    _drawRichText(
      canvas,
      TextSpan(text: '8', style: numStyle),
      Offset(w * 0.35, h * 0.84),
    );

    // House 9 (left bottom)
    _drawRichText(
      canvas,
      TextSpan(text: '9', style: numStyle),
      Offset(w * 0.18, h * 0.67),
    );
    _drawRichText(
      canvas,
      TextSpan(text: 'Mo', style: planetStyle),
      Offset(w * 0.18, h * 0.73),
    );

    // House 10 (left center)
    _drawRichText(
      canvas,
      TextSpan(text: '10', style: numStyle),
      Offset(w * 0.30, h * 0.44),
    );
    _drawRichText(
      canvas,
      TextSpan(text: 'Ma\nSa', style: planetStyle),
      Offset(w * 0.30, h * 0.52),
    );

    // House 11 (left top)
    _drawRichText(
      canvas,
      TextSpan(text: '11', style: numStyle),
      Offset(w * 0.18, h * 0.33),
    );
    _drawRichText(
      canvas,
      TextSpan(
        style: planetStyle,
        children: const [
          TextSpan(text: 'Me'),
          TextSpan(
            text: '(R)',
            style: TextStyle(color: AppColors.goldOrange, fontSize: 10),
          ),
          TextSpan(text: '\nVe'),
        ],
      ),
      Offset(w * 0.18, h * 0.42),
    );

    // House 12 (top left)
    _drawRichText(
      canvas,
      TextSpan(text: '12', style: numStyle),
      Offset(w * 0.35, h * 0.16),
    );
    _drawRichText(
      canvas,
      TextSpan(text: 'Su', style: planetStyle),
      Offset(w * 0.35, h * 0.22),
    );
  }

  void _drawRichText(Canvas canvas, TextSpan textSpan, Offset offset) {
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        offset.dx - textPainter.width / 2,
        offset.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant KundaliChartPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
