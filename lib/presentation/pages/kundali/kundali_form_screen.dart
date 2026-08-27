import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';

const List<Shadow> _textShadows = [
  Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
];

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
    // Video Background Initialization
    _videoController =
        VideoPlayerController.asset('assets/videos/homescreenbg.mp4')
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

    // Rotation animation for rashichakra / loading spinner
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
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1998, 1, 24),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.goldPrimary,
              onPrimary: Colors.black,
              surface: AppColors.cardDark,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.spaceDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Format: 24 Jan 1998
        final List<String> months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        _dateController.text =
            "${picked.day} ${months[picked.month - 1]} ${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 10, minute: 15),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.goldPrimary,
              onPrimary: Colors.black,
              surface: AppColors.cardDark,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.spaceDark,
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
  void _showAyanamsaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.spaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppColors.goldPrimary, width: 1.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SELECT AYANAMSA',
                style: GoogleFonts.cinzel(
                  color: AppColors.goldPrimary,
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
                          color: isSelected
                              ? AppColors.goldPrimary
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.goldPrimary,
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

    // Loop through step text
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
    return Scaffold(
      backgroundColor: AppColors.spaceDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Video/Image
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
            // Dark transparent cover
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.20)),
            ),

            // Main Content
            SafeArea(
              bottom: false,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _isCalculating
                    ? _buildLoadingScreen()
                    : (_showDetailedReport
                          ? _buildDetailedReportScreen()
                          : (_showResult
                                ? _buildResultScreen()
                                : _buildFormScreen())),
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
  Widget _buildFormScreen() {
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
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      shadows: _textShadows,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Accurate information ensures precise Kundali results',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 12,
                      letterSpacing: 0.2,
                      shadows: _textShadows,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // 1. FULL NAME
            _buildLabelRow(Icons.person_outline, 'FULL NAME'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hintText: 'Aarav Sharma',
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 2. GENDER
            _buildLabelRow(null, 'GENDER'),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildGenderButton('MALE'),
                const SizedBox(width: 10),
                _buildGenderButton('FEMALE'),
                const SizedBox(width: 10),
                _buildGenderButton('OTHER'),
              ],
            ),
            const SizedBox(height: 24),

            // 3. DATE OF BIRTH
            _buildLabelRow(Icons.calendar_month_outlined, 'DATE OF BIRTH'),
            const SizedBox(height: 8),
            _buildClickableField(
              controller: _dateController,
              hintText: 'Select date of birth',
              onTap: () => _selectDate(context),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please select date of birth';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 4. TIME OF BIRTH
            _buildLabelRow(Icons.access_time, 'TIME OF BIRTH'),
            const SizedBox(height: 8),
            _buildClickableField(
              controller: _timeController,
              hintText: 'Select time of birth',
              onTap: () => _selectTime(context),
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
                color: Colors.white70,
                fontSize: 11,
                shadows: _textShadows,
              ),
            ),
            const SizedBox(height: 24),

            // 5. PLACE OF BIRTH
            _buildLabelRow(Icons.location_on_outlined, 'PLACE OF BIRTH'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _placeController,
              hintText: 'Mumbai, Maharashtra',
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
              onTap: _showAyanamsaPicker,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF16112C).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accentPurple.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AYANAMSA: $_selectedAyanamsa',
                      style: GoogleFonts.cinzel(
                        color: AppColors.accentPurple,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        shadows: _textShadows,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Standard Vedic calculation method used by most Indian astrologers',
                      style: GoogleFonts.roboto(
                        color: Colors.white70,
                        fontSize: 10,
                        shadows: _textShadows,
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
  Widget _buildLoadingScreen() {
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
                  'assets/images/Component/rashichakra.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback design if image is missing
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.goldPrimary,
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_awesome,
                          color: AppColors.goldPrimary,
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
                color: AppColors.goldPrimary,
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
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Simple animated progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 150,
                height: 4,
                child: LinearProgressIndicator(
                  value: (_loadingStep + 1) / _loadingSteps.length,
                  backgroundColor: AppColors.borderDark,
                  color: AppColors.goldPrimary,
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
  Widget _buildResultScreen() {
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
                const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.goldPrimary,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Back',
                  style: GoogleFonts.roboto(
                    color: AppColors.goldPrimary,
                    fontSize: 16,
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
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              shadows: _textShadows,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_dateController.text} • ${_timeController.text}',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              shadows: _textShadows,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _placeController.text,
            style: GoogleFonts.roboto(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
              shadows: _textShadows,
            ),
          ),
          const SizedBox(height: 24),

          // 3. Tab Bar (CHART, PLANETS, VIMSHOTTARI)
          _buildTabBar(),
          const SizedBox(height: 24),

          // 4. Tab Content Switcher
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _activeTab == 0
                ? _buildChartTab()
                : (_activeTab == 1
                      ? _buildPlanetsTab()
                      : _buildVimshottariTab()),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(0, 'CHART'),
          _buildTabItem(1, 'PLANETS'),
          _buildTabItem(2, 'VIMSHOTTARI'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
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
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
                letterSpacing: 0.8,
                shadows: isSelected ? null : _textShadows,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- CHART TAB ---
  Widget _buildChartTab() {
    return Column(
      key: const ValueKey('chart_tab'),
      children: [
        // Sign Info Row (Lagna, Moon, Sun)
        Row(
          children: [
            _buildSignInfoCard('LAGNA', 'Pisces', '♓', Colors.purpleAccent),
            const SizedBox(width: 8),
            _buildSignInfoCard('MOON', 'Scorpio', '♏', Colors.pinkAccent),
            const SizedBox(width: 8),
            _buildSignInfoCard('SUN', 'Aquarius', '♒', Colors.deepPurpleAccent),
          ],
        ),
        const SizedBox(height: 20),

        // Custom painted North Indian chart card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0C071D).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1.05,
                child: CustomPaint(painter: KundaliChartPainter()),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NORTH INDIAN STYLE',
                    style: GoogleFonts.cinzel(
                      color: AppColors.goldPrimary,
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
                        color: Colors.white70,
                        fontSize: 11,
                        shadows: _textShadows,
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
        _buildPlanetPositionsCard(),
        const SizedBox(height: 24),

        // View Detailed Report Button
        _buildViewReportButton(),
      ],
    );
  }

  // --- PLANETS TAB ---
  Widget _buildPlanetsTab() {
    return Column(
      key: const ValueKey('planets_tab'),
      children: [
        _buildPlanetPositionsCard(isExpanded: true),
        const SizedBox(height: 24),
        _buildViewReportButton(),
      ],
    );
  }

  // --- VIMSHOTTARI TAB ---
  Widget _buildVimshottariTab() {
    return Column(
      key: const ValueKey('vimshottari_tab'),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0C071D).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: 0.2),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VIMSHOTTARI MAHADASHAS',
                style: GoogleFonts.cinzel(
                  color: AppColors.goldPrimary,
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
                isPast: true,
              ),
              _buildTimelineItem(
                'Saturn Dasha',
                '19 Years',
                '2006 - 2025',
                isPast: true,
              ),
              _buildTimelineItem(
                'Mercury Dasha',
                '17 Years',
                '2025 - 2042',
                isCurrent: true,
              ),
              _buildTimelineItem('Ketu Dasha', '7 Years', '2042 - 2049'),
              _buildTimelineItem(
                'Venus Dasha',
                '20 Years',
                '2049 - 2069',
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildViewReportButton(),
      ],
    );
  }

  // --- Helper Widgets ---
  Widget _buildSignInfoCard(
    String label,
    String sign,
    String symbol,
    Color symbolColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0x15FFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.goldPrimary.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.cinzel(
                color: AppColors.goldPrimary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                shadows: _textShadows,
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  shadows: _textShadows,
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

  Widget _buildPlanetPositionsCard({bool isExpanded = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: 0.2),
          width: 1.2,
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/background/home_bg.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black87, BlendMode.darken),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PLANET POSITIONS',
            style: GoogleFonts.cinzel(
              color: AppColors.goldPrimary,
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
                _buildPlanetItem('☉', 'Su', 'H12'),
                _buildPlanetItem('☽', 'Mo', 'H9'),
                _buildPlanetItem('♂', 'Ma', 'H10'),
                _buildPlanetItem('☿', 'Me', 'H11', isRetrograde: true),
                _buildPlanetItem('♃', 'Ju', 'H4'),
                _buildPlanetItem('♀', 'Ve', 'H11'),
                _buildPlanetItem('♄', 'Sa', 'H10'),
                _buildPlanetItem('☊', 'Ra', 'H7', isRetrograde: true),
                _buildPlanetItem('☋', 'Ke', 'H1', isRetrograde: true),
              ],
            ),
          ] else ...[
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPlanetDetailRow(
                  '☉',
                  'Sun',
                  'Pisces',
                  'H12',
                  '29° 12\'',
                  'Revati',
                ),
                _buildPlanetDetailRow(
                  '☽',
                  'Moon',
                  'Scorpio',
                  'H9',
                  '14° 02\'',
                  'Anuradha',
                ),
                _buildPlanetDetailRow(
                  '♂',
                  'Mars',
                  'Capricorn',
                  'H10',
                  '10° 45\'',
                  'Shravana',
                ),
                _buildPlanetDetailRow(
                  '☿',
                  'Mercury (R)',
                  'Aquarius',
                  'H11',
                  '18° 10\'',
                  'Shatabhisha',
                  isRetrograde: true,
                ),
                _buildPlanetDetailRow(
                  '♃',
                  'Jupiter',
                  'Cancer',
                  'H4',
                  '04° 15\'',
                  'Pushya',
                ),
                _buildPlanetDetailRow(
                  '♀',
                  'Venus',
                  'Aquarius',
                  'H11',
                  '12° 30\'',
                  'Shatabhisha',
                ),
                _buildPlanetDetailRow(
                  '♄',
                  'Saturn',
                  'Capricorn',
                  'H10',
                  '22° 40\'',
                  'Dhanishta',
                ),
                _buildPlanetDetailRow(
                  '☊',
                  'Rahu (R)',
                  'Libra',
                  'H7',
                  '07° 50\'',
                  'Swati',
                  isRetrograde: true,
                ),
                _buildPlanetDetailRow(
                  '☋',
                  'Ketu (R)',
                  'Aries',
                  'H1',
                  '07° 50\'',
                  'Ashwini',
                  isRetrograde: true,
                ),
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
    String house, {
    bool isRetrograde = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          symbol,
          style: GoogleFonts.roboto(
            color: AppColors.goldPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: _textShadows,
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
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  shadows: _textShadows,
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
                color: Colors.white70,
                fontSize: 10,
                shadows: _textShadows,
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
    String nakshatra, {
    bool isRetrograde = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderDark.withValues(alpha: 0.3),
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
                color: AppColors.goldPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: _textShadows,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                shadows: _textShadows,
              ),
            ),
          ),
          Expanded(
            child: Text(
              house,
              style: GoogleFonts.roboto(
                color: AppColors.goldPrimary,
                fontSize: 12,
                shadows: _textShadows,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              sign,
              style: GoogleFonts.roboto(
                color: Colors.white70,
                fontSize: 12,
                shadows: _textShadows,
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
                    color: Colors.white,
                    fontSize: 12,
                    shadows: _textShadows,
                  ),
                ),
                Text(
                  nakshatra,
                  style: GoogleFonts.roboto(
                    color: Colors.white60,
                    fontSize: 10,
                    shadows: _textShadows,
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
    String years, {
    bool isPast = false,
    bool isCurrent = false,
    bool isLast = false,
  }) {
    Color dotColor = Colors.white38;
    Color textColor = Colors.white70;
    if (isCurrent) {
      dotColor = AppColors.goldOrange;
      textColor = Colors.white;
    } else if (isPast) {
      dotColor = AppColors.goldPrimary.withValues(alpha: 0.8);
      textColor = Colors.white.withValues(alpha: 0.7);
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
                    color: AppColors.borderDark.withValues(alpha: 0.5),
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
                          shadows: _textShadows,
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
                            'CURRENT',
                            style: GoogleFonts.roboto(
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
                      color: Colors.white60,
                      fontSize: 11,
                      shadows: _textShadows,
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

  Widget _buildViewReportButton() {
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
          color: const Color(0xFF1E1B30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDark, width: 1.5),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'VIEW DETAILED REPORT',
                style: GoogleFonts.cinzel(
                  color: AppColors.goldPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AppColors.goldPrimary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SCREEN 4: DETAILED REPORT SCREEN
  // ==========================================
  Widget _buildDetailedReportScreen() {
    return SingleChildScrollView(
      key: const ValueKey('detailed_report_screen'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Back button & Download circle row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showDetailedReport = false;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.goldPrimary,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Kundali Chart',
                      style: GoogleFonts.roboto(
                        color: AppColors.goldPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        shadows: _textShadows,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.cardDark,
                      content: Text(
                        'Preparing PDF download...',
                        style: GoogleFonts.roboto(color: AppColors.goldPrimary),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.goldPrimary.withValues(alpha: 0.15),
                    border: Border.all(
                      color: AppColors.goldPrimary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.file_download_outlined,
                      color: AppColors.goldPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Title
          Text(
            'DETAILED REPORT',
            style: GoogleFonts.cinzel(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              shadows: _textShadows,
            ),
          ),
          const SizedBox(height: 24),

          // 3. ASCENDANT (LAGNA) CARD
          _buildReportCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardLabel('ASCENDANT (LAGNA)'),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purple.withValues(alpha: 0.15),
                        border: Border.all(
                          color: Colors.purpleAccent.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '♓',
                          style: TextStyle(
                            color: Colors.purpleAccent,
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
                          Text(
                            'PISCES (MEEN)',
                            style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: _textShadows,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lord: Jupiter - 12°34\'',
                            style: GoogleFonts.roboto(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              shadows: _textShadows,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dreamy, spiritual, compassionate nature with artistic gifts',
                            style: GoogleFonts.roboto(
                              color: Colors.white60,
                              fontSize: 12,
                              height: 1.3,
                              shadows: _textShadows,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 4. BIRTH NAKSHATRA CARD
          _buildReportCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCardLabel('BIRTH NAKSHATRA'),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Devata: Mitra',
                          style: GoogleFonts.roboto(
                            color: AppColors.goldPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            shadows: _textShadows,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rashi: Scorpio',
                          style: GoogleFonts.roboto(
                            color: Colors.white70,
                            fontSize: 10,
                            shadows: _textShadows,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'ANURADHA',
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: _textShadows,
                  ),
                ),
                Text(
                  'Lord: Saturn - Pada 3',
                  style: GoogleFonts.roboto(
                    color: Colors.white70,
                    fontSize: 12,
                    shadows: _textShadows,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10, width: 1),
                  ),
                  child: Text(
                    'Anuradha nakshatra natives are devoted, cooperative, and deeply spiritual. They are natural leaders with excellent organizational ability and a gift for bringing harmony to complex situations.',
                    style: GoogleFonts.roboto(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                      shadows: _textShadows,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 5. DOSHA ANALYSIS CARD
          _buildReportCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardLabel('DOSHA ANALYSIS'),
                const SizedBox(height: 16),
                _buildDoshaItem(
                  'Mangal Dosha',
                  'Not Present',
                  'Mars is well-placed. No Mangal Dosha in this chart.',
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildDoshaItem(
                  'Sade Sati',
                  'Active - 2nd Phase',
                  'Saturn transiting over natal Moon. Duration: 2019-2028.',
                  AppColors.goldOrange,
                ),
                const SizedBox(height: 12),
                _buildDoshaItem(
                  'Kaal Sarp Dosha',
                  'Not Present',
                  'All planets are outside the Rahu-Ketu axis.',
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildDoshaItem(
                  'Pitra Dosha',
                  'Mild',
                  'Sun in 12th house with Ketu influence. Minor remedies advised.',
                  Colors.amber,
                ),
              ],
            ),
          ),

          // 6. SARVASHTAKAVARGA CARD
          _buildReportCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardLabel('SARVASHTAKAVARGA'),
                const SizedBox(height: 16),
                _buildSarvashtakavargaRow('☉', 'Sun', 34),
                _buildSarvashtakavargaRow('☽', 'Moon', 36),
                _buildSarvashtakavargaRow('♂', 'Mars', 22),
                _buildSarvashtakavargaRow('☿', 'Mercury', 27),
                _buildSarvashtakavargaRow('♃', 'Jupiter', 39),
                _buildSarvashtakavargaRow('♀', 'Venus', 31),
                _buildSarvashtakavargaRow('♄', 'Saturn', 24),
              ],
            ),
          ),

          // 7. RECOMMENDED REMEDIES CARD
          _buildReportCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardLabel('RECOMMENDED REMEDIES'),
                const SizedBox(height: 16),
                _buildRemedyRow(
                  Icons.diamond_outlined,
                  Colors.blueAccent,
                  'Yellow Sapphire (Pukhraj)',
                  'Strengthen Jupiter • Ring finger, gold setting',
                ),
                const SizedBox(height: 16),
                _buildRemedyRow(
                  Icons.fireplace_outlined,
                  Colors.amberAccent,
                  'Thursday Puja',
                  'Offer bananas & sweets to Lord Vishnu',
                ),
                const SizedBox(height: 16),
                _buildRemedyRow(
                  Icons.grain_outlined,
                  Colors.redAccent,
                  'Jupiter Mantra',
                  'Om Gram Greem Graum Sah Guruve Namah - 108x',
                ),
                const SizedBox(height: 16),
                _buildRemedyRow(
                  Icons.water_drop_outlined,
                  Colors.lightBlueAccent,
                  'Sun Offering',
                  'Offer water to the Sun every morning facing east',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 8. DOWNLOAD BUTTON
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.cardDark,
                  content: Text(
                    'Downloading report in background...',
                    style: GoogleFonts.roboto(color: AppColors.goldPrimary),
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

  Widget _buildReportCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 1.0),
      ),
      child: child,
    );
  }

  Widget _buildCardLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.cinzel(
        color: AppColors.goldPrimary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
        shadows: _textShadows,
      ),
    );
  }

  Widget _buildDoshaItem(
    String title,
    String status,
    String description,
    Color badgeColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white10,
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
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  shadows: _textShadows,
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
              color: Colors.white70,
              fontSize: 11,
              shadows: _textShadows,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSarvashtakavargaRow(String symbol, String name, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            symbol,
            style: GoogleFonts.roboto(
              color: AppColors.goldPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              shadows: _textShadows,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(
              name,
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                shadows: _textShadows,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 8,
                color: Colors.white12,
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
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: _textShadows,
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
  ) {
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
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  shadows: _textShadows,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.roboto(
                  color: Colors.white70,
                  fontSize: 11,
                  shadows: _textShadows,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Helper Widgets for Screen elements ---
  Widget _buildLabelRow(IconData? icon, String text) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: AppColors.goldPrimary, size: 16),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: GoogleFonts.cinzel(
            color: AppColors.goldPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            shadows: _textShadows,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: GoogleFonts.roboto(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.roboto(
          color: Colors.white60,
          fontSize: 15,
          shadows: _textShadows,
        ),
        fillColor: Colors.transparent,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: AppColors.goldPrimary.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: AppColors.goldPrimary,
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
    required VoidCallback onTap,
    required String? Function(String?)? validator,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          validator: validator,
          style: GoogleFonts.roboto(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.roboto(
              color: Colors.white60,
              fontSize: 15,
              shadows: _textShadows,
            ),
            fillColor: Colors.transparent,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: AppColors.goldPrimary.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: AppColors.goldPrimary,
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

  Widget _buildGenderButton(String gender) {
    final isSelected = _selectedGender == gender;
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
            color: isSelected ? const Color(0xFFCE7C2E) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : AppColors.goldPrimary.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Center(
            child: Text(
              gender,
              style: GoogleFonts.cinzel(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
                letterSpacing: 0.5,
                shadows: isSelected ? null : _textShadows,
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.goldPrimary.withValues(alpha: 0.7)
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
      ..color = const Color(0xFF0C071D)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h / 2), 32, bgPaint);

    final borderPaint = Paint()
      ..color = AppColors.goldPrimary.withValues(alpha: 0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(w / 2, h / 2), 32, borderPaint);

    // Paint Lagna center text
    _drawRichText(
      canvas,
      TextSpan(
        text: 'LAGNA',
        style: GoogleFonts.cinzel(
          color: AppColors.goldPrimary,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          shadows: _textShadows,
        ),
      ),
      Offset(w / 2, h / 2 - 8),
    );

    _drawRichText(
      canvas,
      TextSpan(
        style: GoogleFonts.roboto(
          color: AppColors.goldPrimary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          shadows: _textShadows,
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
      color: AppColors.goldPrimary.withValues(alpha: 0.7),
      fontSize: 10,
      shadows: _textShadows,
    );
    final planetStyle = TextStyle(
      color: AppColors.textPrimary,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      shadows: _textShadows,
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
