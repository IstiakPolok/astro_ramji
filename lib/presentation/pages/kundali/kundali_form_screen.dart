import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/location_model.dart';
import '../../providers/theme_provider.dart';
import '../../providers/astrology_api_provider.dart';
import '../../widgets/location_autocomplete_field.dart';

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
  LocationModel? _selectedLocation;
  String _selectedGender = 'MALE';
  String _selectedAyanamsa = 'LAHIRI (CHITRAPAKSHA)';
  int _activeTab = 0;

  // Interaction / Loading / Results State
  bool _isCalculating = false;
  bool _showResult = false;
  bool _showDetailedReport = false;
  bool _isDownloadingPdf = false;
  int _loadingStep = 0;
  late AnimationController _rotationController;

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
                context.tr('select_ayanamsa'),
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

  // --- Loading Animation & API Calculation Controller ---
  void _startCalculation() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
      _loadingStep = 0;
    });
    _rotationController.repeat();

    // Trigger API generation with OpenAPI v1 backend
    final dob = _selectedDate != null
        ? '${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
        : '1998-01-24';
    final tob = _selectedTime != null
        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00'
        : '14:30:00';
    final placeId = _selectedLocation?.placeId ?? 'ChIJL_P_CXMEDTkRw0ZiJIefm9E';

    final apiProvider = Provider.of<AstrologyApiProvider>(context, listen: false);
    final kundaliFuture = apiProvider.generateKundali(
      name: _nameController.text.trim(),
      dateOfBirth: dob,
      timeOfBirth: tob,
      placeId: placeId,
      gender: _selectedGender,
      ayanamsa: _selectedAyanamsa,
    );

    int step = 0;
    Timer.periodic(const Duration(milliseconds: 600), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      step++;
      if (step < 4) {
        setState(() {
          _loadingStep = step;
        });
      } else {
        timer.cancel();
        await kundaliFuture;
        if (!mounted) return;
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
                    context.tr('birth_details_title'),
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
                    context.tr('birth_details_sub'),
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
            _buildLabelRow(Icons.person_outline, context.tr('full_name'), isDark),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hintText: context.tr('full_name_hint'),
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
            _buildLabelRow(null, context.tr('gender'), isDark),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildGenderButton('MALE', context.tr('gender_male'), isDark),
                const SizedBox(width: 10),
                _buildGenderButton('FEMALE', context.tr('gender_female'), isDark),
                const SizedBox(width: 10),
                _buildGenderButton('OTHER', context.tr('gender_other'), isDark),
              ],
            ),
            const SizedBox(height: 24),

            // 3. DATE OF BIRTH
            _buildLabelRow(Icons.calendar_month_outlined, context.tr('date_of_birth'), isDark),
            const SizedBox(height: 8),
            _buildClickableField(
              controller: _dateController,
              hintText: context.tr('select_date_hint'),
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
            _buildLabelRow(Icons.access_time, context.tr('time_of_birth'), isDark),
            const SizedBox(height: 8),
            _buildClickableField(
              controller: _timeController,
              hintText: context.tr('select_time_hint'),
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
              context.tr('birth_time_accuracy'),
              style: GoogleFonts.roboto(
                color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                fontSize: 11,
                shadows: textShadows,
              ),
            ),
            const SizedBox(height: 24),

            // 5. PLACE OF BIRTH
            _buildLabelRow(Icons.location_on_outlined, context.tr('place_of_birth'), isDark),
            const SizedBox(height: 8),
            LocationAutocompleteField(
              controller: _placeController,
              label: '',
              hint: context.tr('place_of_birth_hint'),
              isDark: isDark,
              onLocationSelected: (loc) {
                setState(() {
                  _selectedLocation = loc;
                });
              },
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
                      '${context.tr('ayanamsa_label')}: $_selectedAyanamsa',
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
                      context.tr('ayanamsa_sub'),
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
                    context.tr('generate_kundali'),
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

    final loadingSteps = [
      context.tr('locating_coords'),
      context.tr('retrieving_ephemeris'),
      context.tr('calc_lagna'),
      context.tr('struct_houses'),
      context.tr('gen_chart'),
    ];

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
              loadingSteps[_loadingStep].toUpperCase(),
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
              '${context.tr('aligning_celestial')} ${_nameController.text}',
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
                  context.tr('back'),
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
          _buildTabItem(0, context.tr('tab_chart'), isDark),
          _buildTabItem(1, context.tr('tab_planets'), isDark),
          _buildTabItem(2, context.tr('tab_vimshottari'), isDark),
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
    final apiProvider = Provider.of<AstrologyApiProvider>(context);
    final kundaliData = apiProvider.activeKundaliData;

    // Dynamic Ascendant sign
    final ascendant = kundaliData?['ascendant'] as Map<String, dynamic>?;
    final ascSignStr = (ascendant?['sign']?.toString() ?? 'PISCES').toUpperCase();
    final lagnaSign = _formatName(ascSignStr);
    final lagnaSymbol = _rashiSymbolMap[ascSignStr] ?? '♓';
    final lagnaColor = _rashiColorMap[ascSignStr] ?? Colors.purpleAccent;

    // Dynamic Moon sign
    final planetsList = kundaliData?['planets'] as List<dynamic>?;
    final moonPlanet = planetsList?.firstWhere(
      (p) => p is Map && (p['planet']?.toString() ?? '').toUpperCase() == 'MOON',
      orElse: () => null,
    ) as Map<String, dynamic>?;
    final moonSignStr = (moonPlanet?['sign']?.toString() ?? 'SCORPIO').toUpperCase();
    final moonSign = _formatName(moonSignStr);
    final moonSymbol = _rashiSymbolMap[moonSignStr] ?? '♏';
    final moonColor = _rashiColorMap[moonSignStr] ?? Colors.pinkAccent;

    // Dynamic Sun sign
    final sunPlanet = planetsList?.firstWhere(
      (p) => p is Map && (p['planet']?.toString() ?? '').toUpperCase() == 'SUN',
      orElse: () => null,
    ) as Map<String, dynamic>?;
    final sunSignStr = (sunPlanet?['sign']?.toString() ?? 'CAPRICORN').toUpperCase();
    final sunSign = _formatName(sunSignStr);
    final sunSymbol = _rashiSymbolMap[sunSignStr] ?? '♑';
    final sunColor = _rashiColorMap[sunSignStr] ?? Colors.deepPurpleAccent;

    return Column(
      key: const ValueKey('chart_tab'),
      children: [
        // Sign Info Row (Lagna, Moon, Sun)
        Row(
          children: [
            _buildSignInfoCard(context.tr('lagna'), lagnaSign, lagnaSymbol, lagnaColor, isDark),
            const SizedBox(width: 8),
            _buildSignInfoCard(context.tr('moon'), moonSign, moonSymbol, moonColor, isDark),
            const SizedBox(width: 8),
            _buildSignInfoCard(context.tr('sun'), sunSign, sunSymbol, sunColor, isDark),
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
                  painter: KundaliChartPainter(
                    isDark: isDark,
                    kundaliData: kundaliData,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('north_indian_style'),
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
    final apiProvider = Provider.of<AstrologyApiProvider>(context);
    final kundaliData = apiProvider.activeKundaliData;

    final dashas = kundaliData?['dashas']?['vimshottari'] as List<dynamic>?;
    final List<Widget> timelineItems = [];

    if (dashas != null && dashas.isNotEmpty) {
      for (int i = 0; i < dashas.length; i++) {
        final dasha = dashas[i];
        if (dasha is Map<String, dynamic>) {
          final lord = _formatName(dasha['mahadasha_lord']?.toString() ?? '');
          final duration = '${dasha['duration_years'] ?? 0} Years';
          final startYear = _formatYear(dasha['start_date']);
          final endYear = _formatYear(dasha['end_date']);
          final years = (startYear.isNotEmpty && endYear.isNotEmpty)
              ? '$startYear - $endYear'
              : '';
          final isCurrent = dasha['is_current'] == true;
          final pct = (dasha['percentage_elapsed'] as num?)?.toDouble() ?? 0.0;
          final isPast = !isCurrent && pct >= 100.0;
          final isLast = i == dashas.length - 1;

          timelineItems.add(
            _buildTimelineItem(
              '$lord Dasha',
              duration,
              years,
              isDark,
              isPast: isPast,
              isCurrent: isCurrent,
              isLast: isLast,
            ),
          );
        }
      }
    }

    if (timelineItems.isEmpty) {
      timelineItems.addAll([
        _buildTimelineItem('Jupiter Dasha', '16 Years', '1990 - 2006', isDark, isPast: true),
        _buildTimelineItem('Saturn Dasha', '19 Years', '2006 - 2025', isDark, isPast: true),
        _buildTimelineItem('Mercury Dasha', '17 Years', '2025 - 2042', isDark, isCurrent: true),
        _buildTimelineItem('Ketu Dasha', '7 Years', '2042 - 2049', isDark),
        _buildTimelineItem('Venus Dasha', '20 Years', '2049 - 2069', isDark, isLast: true),
      ]);
    }

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
                context.tr('vimshottari_mahadashas'),
                style: GoogleFonts.cinzel(
                  color: goldColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 20),
              ...timelineItems,
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
    final apiProvider = Provider.of<AstrologyApiProvider>(context);
    final kundaliData = apiProvider.activeKundaliData;

    final rawPlanets = kundaliData?['planets'] as List<dynamic>?;
    final List<Map<String, dynamic>> planetsToDisplay;

    if (rawPlanets != null && rawPlanets.isNotEmpty) {
      planetsToDisplay = rawPlanets.whereType<Map<String, dynamic>>().toList();
    } else {
      planetsToDisplay = const [
        {'planet': 'SUN', 'sign': 'PISCES', 'house': 12, 'sign_degree_dms': "29° 12'", 'nakshatra': 'REVATI', 'retrograde': false},
        {'planet': 'MOON', 'sign': 'SCORPIO', 'house': 9, 'sign_degree_dms': "14° 02'", 'nakshatra': 'ANURADHA', 'retrograde': false},
        {'planet': 'MARS', 'sign': 'CAPRICORN', 'house': 10, 'sign_degree_dms': "10° 45'", 'nakshatra': 'SHRAVANA', 'retrograde': false},
        {'planet': 'MERCURY', 'sign': 'AQUARIUS', 'house': 11, 'sign_degree_dms': "18° 10'", 'nakshatra': 'SHATABHISHA', 'retrograde': true},
        {'planet': 'JUPITER', 'sign': 'CANCER', 'house': 4, 'sign_degree_dms': "04° 15'", 'nakshatra': 'PUSHYA', 'retrograde': false},
        {'planet': 'VENUS', 'sign': 'AQUARIUS', 'house': 11, 'sign_degree_dms': "12° 30'", 'nakshatra': 'SHATABHISHA', 'retrograde': false},
        {'planet': 'SATURN', 'sign': 'CAPRICORN', 'house': 10, 'sign_degree_dms': "22° 40'", 'nakshatra': 'DHANISHTA', 'retrograde': false},
        {'planet': 'RAHU', 'sign': 'LIBRA', 'house': 7, 'sign_degree_dms': "07° 50'", 'nakshatra': 'SWATI', 'retrograde': true},
        {'planet': 'KETU', 'sign': 'ARIES', 'house': 1, 'sign_degree_dms': "07° 50'", 'nakshatra': 'ASHWINI', 'retrograde': true},
      ];
    }

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
            context.tr('planet_positions'),
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
              children: planetsToDisplay.map((p) {
                final pName = (p['planet']?.toString() ?? '').toUpperCase();
                return _buildPlanetItem(
                  _planetSymbolMap[pName] ?? '★',
                  _planetAbbrMap[pName] ?? _formatName(pName),
                  'H${p['house'] ?? 1}',
                  isDark,
                  isRetrograde: p['retrograde'] == true,
                );
              }).toList(),
            ),
          ] else ...[
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: planetsToDisplay.map((p) {
                final pName = (p['planet']?.toString() ?? '').toUpperCase();
                final fullName = _formatName(pName);
                final signName = _formatName(p['sign']?.toString() ?? '');
                final houseStr = 'H${p['house'] ?? 1}';
                final degreeStr = p['sign_degree_dms']?.toString() ??
                    (p['sign_degree'] != null
                        ? '${(p['sign_degree'] as num).toStringAsFixed(1)}°'
                        : '0°');
                final nakshatraStr = _formatNakshatra(p['nakshatra']?.toString() ?? '');
                final isRetro = p['retrograde'] == true;

                return _buildPlanetDetailRow(
                  _planetSymbolMap[pName] ?? '★',
                  isRetro ? '$fullName (R)' : fullName,
                  signName,
                  houseStr,
                  degreeStr,
                  nakshatraStr,
                  isDark,
                  isRetrograde: isRetro,
                );
              }).toList(),
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
                          child: Text(
                            context.tr('current'),
                            style: const TextStyle(
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
                context.tr('view_detailed_report'),
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
                  context.tr('chart_overview'),
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
            context.tr('detailed_kundali_report'),
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
          Builder(builder: (context) {
            final apiProvider = Provider.of<AstrologyApiProvider>(context);
            final kundaliData = apiProvider.activeKundaliData;
            final ascendant = kundaliData?['ascendant'] as Map<String, dynamic>?;
            final ascSignStr = (ascendant?['sign']?.toString() ?? 'PISCES').toUpperCase();
            final lagnaSign = _formatName(ascSignStr);
            final lagnaSanskrit = _rashiSanskritMap[ascSignStr] ?? 'MEENA';
            final lagnaLord = _formatName(ascendant?['lord']?.toString() ?? 'Jupiter');
            final lagnaDescription = ascendant?['description']?.toString() ??
                'Your Lagna in $lagnaSign gives you an empathetic, deeply spiritual, and intuitive disposition. You possess strong artistic sensitivities and emotional depth.';

            return _buildReportCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardLabel(context.tr('ascendant_nature'), isDark),
                  const SizedBox(height: 12),
                  Text(
                    'Lagna: $lagnaSign ($lagnaSanskrit) · Ruler: $lagnaLord',
                    style: GoogleFonts.roboto(
                      color: goldColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      shadows: textShadows,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lagnaDescription,
                    style: GoogleFonts.roboto(
                      color: isDark ? Colors.white.withValues(alpha: 0.85) : AppColors.textPrimaryLight,
                      fontSize: 12,
                      height: 1.5,
                      shadows: textShadows,
                    ),
                  ),
                ],
              ),
            );
          }),

          // 4. PLANETARY STRENGTHS (SHADBALA) CARD
          _buildReportCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardLabel(context.tr('shadbala_title'), isDark),
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
                _buildCardLabel(context.tr('dosha_yoga_analysis'), isDark),
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
                _buildCardLabel(context.tr('sarvashtakavarga'), isDark),
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
                _buildCardLabel(context.tr('recommended_remedies'), isDark),
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
            onTap: _isDownloadingPdf ? null : () => _handleDownloadPdf(isDark),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: _isDownloadingPdf
                    ? const LinearGradient(
                        colors: [Color(0xFF9E7A35), Color(0xFFD4A827)],
                      )
                    : AppColors.buttonGradient,
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
                    if (_isDownloadingPdf) ...[
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Downloading PDF...',
                        style: GoogleFonts.cinzel(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.download, color: Colors.black, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('download_pdf_report'),
                        style: GoogleFonts.cinzel(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
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

  Future<void> _handleDownloadPdf(bool isDark) async {
    if (_isDownloadingPdf) return;

    final apiProvider = Provider.of<AstrologyApiProvider>(context, listen: false);
    String? profileId = apiProvider.activeProfile?.id;

    setState(() {
      _isDownloadingPdf = true;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        backgroundColor: isDark ? AppColors.cardDark : AppColors.spaceLight,
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.goldOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Downloading Kundali PDF report...',
                style: GoogleFonts.roboto(
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    try {
      // 1. Ensure profile exists or auto-generate
      if (profileId == null || profileId.isEmpty) {
        final dob = _selectedDate != null
            ? '${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
            : '1998-01-24';
        final tob = _selectedTime != null
            ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00'
            : '14:30:00';
        final placeId = _selectedLocation?.placeId ?? 'ChIJL_P_CXMEDTkRw0ZiJIefm9E';

        final success = await apiProvider.generateKundali(
          name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Aarav Sharma',
          dateOfBirth: dob,
          timeOfBirth: tob,
          placeId: placeId,
          gender: _selectedGender,
          ayanamsa: _selectedAyanamsa,
        );

        if (success) {
          profileId = apiProvider.activeProfile?.id;
        }
      }

      // Fallback to verified active profile if needed
      profileId ??= '55c085df-2f87-48ea-898e-08bf32fb9acf';

      debugPrint('Downloading Kundali PDF for profile ID: $profileId');
      final bytes = await apiProvider.downloadKundaliPdf(profileId);

      if (bytes == null || bytes.isEmpty) {
        throw Exception('Server did not return PDF bytes');
      }

      // 2. Resolve save directory
      Directory? dir;
      try {
        dir = await getApplicationDocumentsDirectory();
      } catch (_) {}
      try {
        dir ??= await getDownloadsDirectory();
      } catch (_) {}
      try {
        dir ??= await getTemporaryDirectory();
      } catch (_) {}

      if (dir == null) {
        throw Exception('Could not access device storage directory');
      }
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final rawName = _nameController.text.trim();
      final cleanName = rawName.isNotEmpty
          ? rawName.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_')
          : 'Aarav_Sharma';
      final fileName = 'Kundali_$cleanName.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      debugPrint('Saved Kundali PDF to: ${file.path} (${bytes.length} bytes)');

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // 3. Show Success Dialog / Bottom Sheet
      _showDownloadSuccessSheet(
        isDark: isDark,
        fileName: fileName,
        fileSizeKb: (bytes.length / 1024).toStringAsFixed(1),
        filePath: file.path,
      );

      // 4. Also attempt direct launch via OpenFilex
      try {
        await OpenFilex.open(file.path);
      } catch (openErr) {
        debugPrint('OpenFilex auto-open notice: $openErr');
      }
    } catch (e) {
      debugPrint('Error in _handleDownloadPdf: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFB71C1C),
          duration: const Duration(seconds: 4),
          content: Text(
            'Download failed: $e',
            style: GoogleFonts.roboto(color: Colors.white),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingPdf = false;
        });
      }
    }
  }

  void _showDownloadSuccessSheet({
    required bool isDark,
    required String fileName,
    required String fileSizeKb,
    required String filePath,
  }) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF15102A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: goldColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF4CAF50),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Kundali PDF Downloaded!',
                  style: GoogleFonts.cinzel(
                    color: goldColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    shadows: textShadows,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$fileName • $fileSizeKb KB',
                  style: GoogleFonts.roboto(
                    color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Saved to App Documents & Files',
                  style: GoogleFonts.roboto(
                    color: isDark ? Colors.white38 : AppColors.textMutedLight,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: goldColor.withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Done',
                          style: GoogleFonts.cinzel(
                            color: goldColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          try {
                            await OpenFilex.open(filePath);
                          } catch (_) {}
                        },
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.black, size: 18),
                        label: Text(
                          'Open PDF',
                          style: GoogleFonts.cinzel(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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

  Widget _buildGenderButton(String genderCode, String genderLabel, bool isDark) {
    final isSelected = _selectedGender == genderCode;
    final goldColor = AppColors.getGold(isDark);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = genderCode;
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
}

// ==========================================
// KUNDALI CONSTANTS & HELPER MAPPINGS
// ==========================================
const Map<String, int> _rashiNumberMap = {
  'ARIES': 1,
  'TAURUS': 2,
  'GEMINI': 3,
  'CANCER': 4,
  'LEO': 5,
  'VIRGO': 6,
  'LIBRA': 7,
  'SCORPIO': 8,
  'SAGITTARIUS': 9,
  'CAPRICORN': 10,
  'AQUARIUS': 11,
  'PISCES': 12,
};

const Map<String, String> _rashiSymbolMap = {
  'ARIES': '♈',
  'TAURUS': '♉',
  'GEMINI': '♊',
  'CANCER': '♋',
  'LEO': '♌',
  'VIRGO': '♍',
  'LIBRA': '♎',
  'SCORPIO': '♏',
  'SAGITTARIUS': '♐',
  'CAPRICORN': '♑',
  'AQUARIUS': '♒',
  'PISCES': '♓',
};

const Map<String, String> _rashiSanskritMap = {
  'ARIES': 'MESHA',
  'TAURUS': 'VRISHABHA',
  'GEMINI': 'MITHUNA',
  'CANCER': 'KARKA',
  'LEO': 'SIMHA',
  'VIRGO': 'KANYA',
  'LIBRA': 'TULA',
  'SCORPIO': 'VRISHCHIKA',
  'SAGITTARIUS': 'DHANU',
  'CAPRICORN': 'MAKARA',
  'AQUARIUS': 'KUMBHA',
  'PISCES': 'MEENA',
};

const Map<String, Color> _rashiColorMap = {
  'ARIES': Color(0xFFEF5350),
  'TAURUS': Color(0xFF66BB6A),
  'GEMINI': Color(0xFFFFA726),
  'CANCER': Color(0xFF42A5F5),
  'LEO': Color(0xFFFF7043),
  'VIRGO': Color(0xFF26A69A),
  'LIBRA': Color(0xFFAB47BC),
  'SCORPIO': Color(0xFFEC407A),
  'SAGITTARIUS': Color(0xFFFFB300),
  'CAPRICORN': Color(0xFF78909C),
  'AQUARIUS': Color(0xFF5C6BC0),
  'PISCES': Color(0xFF8E24AA),
};

const Map<String, String> _planetSymbolMap = {
  'SUN': '☉',
  'MOON': '☽',
  'MARS': '♂',
  'MERCURY': '☿',
  'JUPITER': '♃',
  'VENUS': '♀',
  'SATURN': '♄',
  'RAHU': '☊',
  'KETU': '☋',
  'URANUS': '♅',
  'NEPTUNE': '♆',
  'PLUTO': '♇',
};

const Map<String, String> _planetAbbrMap = {
  'SUN': 'Su',
  'MOON': 'Mo',
  'MARS': 'Ma',
  'MERCURY': 'Me',
  'JUPITER': 'Ju',
  'VENUS': 'Ve',
  'SATURN': 'Sa',
  'RAHU': 'Ra',
  'KETU': 'Ke',
};

String _formatName(String raw) {
  if (raw.isEmpty) return '';
  final upper = raw.toUpperCase();
  return upper[0] + upper.substring(1).toLowerCase();
}

String _formatNakshatra(String raw) {
  if (raw.isEmpty) return '';
  return raw
      .split('_')
      .map((part) => part.isNotEmpty ? part[0].toUpperCase() + part.substring(1).toLowerCase() : '')
      .join(' ');
}

String _formatYear(dynamic dateStr) {
  if (dateStr == null) return '';
  final str = dateStr.toString();
  if (str.length >= 4) {
    return str.substring(0, 4);
  }
  return str;
}

class _HouseLayoutData {
  final Offset signPos;
  final Offset planetsPos;

  const _HouseLayoutData({
    required this.signPos,
    required this.planetsPos,
  });
}

// ==========================================
// CUSTOM PAINTER FOR NORTH INDIAN KUNDALI
// ==========================================
class KundaliChartPainter extends CustomPainter {
  final bool isDark;
  final Map<String, dynamic>? kundaliData;

  KundaliChartPainter({
    this.isDark = true,
    this.kundaliData,
  });

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
    canvas.drawCircle(Offset(w / 2, h / 2), 34, bgPaint);

    final borderPaint = Paint()
      ..color = isDark
          ? AppColors.goldPrimary.withValues(alpha: 0.35)
          : AppColors.goldPrimaryDark.withValues(alpha: 0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(w / 2, h / 2), 34, borderPaint);

    final textShadows = AppColors.getTextShadows(isDark);

    // Parse Ascendant info from kundaliData
    final ascendant = kundaliData?['ascendant'] as Map<String, dynamic>?;
    final ascSign = (ascendant?['sign']?.toString() ?? 'PISCES').toUpperCase();
    final ascSignNum = _rashiNumberMap[ascSign] ?? 12;
    final ascDegreeDms = ascendant?['degree_dms']?.toString() ?? "16°11'";
    final ascSanskrit = _rashiSanskritMap[ascSign] ?? 'MEENA';
    final ascSymbol = _rashiSymbolMap[ascSign] ?? '♓';

    // Central Circle Labels
    _drawRichText(
      canvas,
      TextSpan(
        text: 'LAGNA',
        style: GoogleFonts.cinzel(
          color: goldStrokeColor,
          fontSize: 7.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          shadows: textShadows,
        ),
      ),
      Offset(w / 2, h / 2 - 14),
    );

    _drawRichText(
      canvas,
      TextSpan(
        style: GoogleFonts.roboto(
          color: goldStrokeColor,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          shadows: textShadows,
        ),
        children: [
          TextSpan(
            text: '$ascSymbol ',
            style: TextStyle(
              color: _rashiColorMap[ascSign] ??
                  (isDark ? Colors.purpleAccent : AppColors.goldOrange),
              fontSize: 10.5,
            ),
          ),
          TextSpan(text: ascSanskrit),
        ],
      ),
      Offset(w / 2, h / 2 + 1),
    );

    _drawRichText(
      canvas,
      TextSpan(
        text: ascDegreeDms,
        style: GoogleFonts.roboto(
          color: isDark ? Colors.white60 : AppColors.textMutedLight,
          fontSize: 8,
          fontWeight: FontWeight.w500,
          shadows: textShadows,
        ),
      ),
      Offset(w / 2, h / 2 + 15),
    );

    // 5. Compute Sign Numbers for all 12 Houses
    final housesList = kundaliData?['houses'] as List<dynamic>?;
    final Map<int, int> houseToSignNumber = {};
    if (housesList != null && housesList.isNotEmpty) {
      for (final h in housesList) {
        if (h is Map<String, dynamic>) {
          final houseNum = (h['house_number'] as num?)?.toInt() ?? 1;
          final signStr = (h['sign']?.toString() ?? '').toUpperCase();
          if (_rashiNumberMap.containsKey(signStr)) {
            houseToSignNumber[houseNum] = _rashiNumberMap[signStr]!;
          }
        }
      }
    }
    // Fallback formula: house 1 = ascSignNum, house 2 = (ascSignNum % 12) + 1, etc.
    for (int h = 1; h <= 12; h++) {
      houseToSignNumber.putIfAbsent(h, () => ((ascSignNum + h - 2) % 12) + 1);
    }

    // 6. Group Planets by House
    final planetsList = kundaliData?['planets'] as List<dynamic>?;
    final Map<int, List<Map<String, dynamic>>> housePlanets = {
      for (int i = 1; i <= 12; i++) i: [],
    };

    if (planetsList != null && planetsList.isNotEmpty) {
      for (final p in planetsList) {
        if (p is Map<String, dynamic>) {
          final houseNum = (p['house'] as num?)?.toInt();
          if (houseNum != null && houseNum >= 1 && houseNum <= 12) {
            housePlanets[houseNum]!.add(p);
          }
        }
      }
    } else {
      // Default / fallback sample planets
      housePlanets[1] = [
        {'planet': 'SATURN', 'retrograde': false}
      ];
      housePlanets[6] = [
        {'planet': 'RAHU', 'retrograde': true}
      ];
      housePlanets[9] = [
        {'planet': 'MOON', 'retrograde': false}
      ];
      housePlanets[10] = [
        {'planet': 'MERCURY', 'retrograde': false},
        {'planet': 'VENUS', 'retrograde': true},
      ];
      housePlanets[11] = [
        {'planet': 'SUN', 'retrograde': false}
      ];
      housePlanets[12] = [
        {'planet': 'MARS', 'retrograde': false},
        {'planet': 'JUPITER', 'retrograde': false},
        {'planet': 'KETU', 'retrograde': true},
      ];
    }

    // 7. Styling for Numbers and Planets
    final numStyle = TextStyle(
      color: isDark
          ? AppColors.goldPrimary.withValues(alpha: 0.75)
          : AppColors.goldPrimaryDark,
      fontSize: 10,
      fontWeight: FontWeight.w600,
      shadows: textShadows,
    );

    final planetBaseStyle = TextStyle(
      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
      fontSize: 11,
      fontWeight: FontWeight.bold,
      shadows: textShadows,
    );

    // 8. Coordinates mapping for 12 Houses (North Indian Anti-Clockwise Layout)
    final houseCoords = <int, _HouseLayoutData>{
      1: _HouseLayoutData(
        signPos: Offset(w / 2, h * 0.33),
        planetsPos: Offset(w / 2, h * 0.18),
      ),
      2: _HouseLayoutData(
        signPos: Offset(w * 0.35, h * 0.15),
        planetsPos: Offset(w * 0.22, h * 0.08),
      ),
      3: _HouseLayoutData(
        signPos: Offset(w * 0.16, h * 0.33),
        planetsPos: Offset(w * 0.09, h * 0.22),
      ),
      4: _HouseLayoutData(
        signPos: Offset(w * 0.33, h * 0.50),
        planetsPos: Offset(w * 0.18, h * 0.50),
      ),
      5: _HouseLayoutData(
        signPos: Offset(w * 0.16, h * 0.67),
        planetsPos: Offset(w * 0.09, h * 0.78),
      ),
      6: _HouseLayoutData(
        signPos: Offset(w * 0.35, h * 0.85),
        planetsPos: Offset(w * 0.22, h * 0.92),
      ),
      7: _HouseLayoutData(
        signPos: Offset(w / 2, h * 0.67),
        planetsPos: Offset(w / 2, h * 0.82),
      ),
      8: _HouseLayoutData(
        signPos: Offset(w * 0.65, h * 0.85),
        planetsPos: Offset(w * 0.78, h * 0.92),
      ),
      9: _HouseLayoutData(
        signPos: Offset(w * 0.84, h * 0.67),
        planetsPos: Offset(w * 0.91, h * 0.78),
      ),
      10: _HouseLayoutData(
        signPos: Offset(w * 0.67, h * 0.50),
        planetsPos: Offset(w * 0.82, h * 0.50),
      ),
      11: _HouseLayoutData(
        signPos: Offset(w * 0.84, h * 0.33),
        planetsPos: Offset(w * 0.91, h * 0.22),
      ),
      12: _HouseLayoutData(
        signPos: Offset(w * 0.65, h * 0.15),
        planetsPos: Offset(w * 0.78, h * 0.08),
      ),
    };

    // 9. Draw Rashi number and planets for each house
    for (int hIndex = 1; hIndex <= 12; hIndex++) {
      final layout = houseCoords[hIndex]!;
      final rashiNum = houseToSignNumber[hIndex] ?? hIndex;
      final planets = housePlanets[hIndex] ?? [];

      // Draw Rashi (zodiac sign) number
      _drawRichText(
        canvas,
        TextSpan(text: '$rashiNum', style: numStyle),
        layout.signPos,
      );

      // Draw Planets if any
      if (planets.isNotEmpty) {
        final style = planets.length > 2
            ? planetBaseStyle.copyWith(fontSize: 9.5)
            : planetBaseStyle;
        final span = _buildPlanetsSpan(planets, style, isDark);
        _drawRichText(canvas, span, layout.planetsPos);
      }
    }
  }

  TextSpan _buildPlanetsSpan(
    List<Map<String, dynamic>> planets,
    TextStyle baseStyle,
    bool isDark,
  ) {
    if (planets.isEmpty) return const TextSpan();
    final children = <InlineSpan>[];

    for (int i = 0; i < planets.length; i++) {
      final p = planets[i];
      final planetStr = (p['planet']?.toString() ?? '').toUpperCase();
      final abbr = _planetAbbrMap[planetStr] ??
          (planetStr.length >= 2
              ? '${planetStr[0]}${planetStr[1].toLowerCase()}'
              : planetStr);
      final isRetro = p['retrograde'] == true;

      // Wrap onto a new line if more than 2 planets
      if (i > 0) {
        if (planets.length > 2 && i % 2 == 0) {
          children.add(const TextSpan(text: '\n'));
        } else {
          children.add(const TextSpan(text: ' '));
        }
      }

      children.add(TextSpan(text: abbr, style: baseStyle));
      if (isRetro) {
        children.add(
          TextSpan(
            text: '(R)',
            style: baseStyle.copyWith(
              color: AppColors.goldOrange,
              fontSize: (baseStyle.fontSize ?? 11) * 0.72,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
    }
    return TextSpan(children: children);
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
      oldDelegate.isDark != isDark || oldDelegate.kundaliData != kundaliData;
}
