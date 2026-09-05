import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../providers/theme_provider.dart';
import 'home/home_page.dart';
import 'kundali/kundali_form_screen.dart';
import 'matching/matching_screen.dart';
import 'settings/settings_screen.dart';
import 'horoscope/horoscope_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  void setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _pages = [
    const HomePage(),
    const KundaliFormScreen(),
    const HoroscopeScreen(),
    const MatchingScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNavigationBar(isDark),
    );
  }

  Widget _buildBottomNavigationBar(bool isDark) {
    final activeColor = AppColors.getGold(isDark);
    final inactiveColor = AppColors.getTextSecondary(isDark);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xE505030A) : const Color(0xF2FFFFFF),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : const Color(0x30D4A827),
            width: 1,
          ),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, context.tr('nav_home'), isDark, activeColor, inactiveColor),
              _buildNavItem(1, Icons.auto_awesome_outlined, context.tr('nav_kundali'), isDark, activeColor, inactiveColor),

              // Glowing Floating center sun button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = 2; // Middle index (Horoscope)
                  });
                },
                child: Transform.translate(
                  offset: const Offset(0, -10),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black : const Color(0xFFFFF9E6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: activeColor,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.4 : 0.25),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.wb_sunny_rounded,
                      color: _currentIndex == 2
                          ? AppColors.goldOrange
                          : activeColor,
                      size: 28,
                    ),
                  ),
                ),
              ),

              _buildNavItem(3, Icons.favorite_border_rounded, context.tr('nav_matching'), isDark, activeColor, inactiveColor),
              _buildNavItem(4, Icons.person_outline_rounded, context.tr('nav_account'), isDark, activeColor, inactiveColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    bool isDark,
    Color activeColor,
    Color inactiveColor,
  ) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? activeColor : inactiveColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.cinzel(
              color: isSelected ? activeColor : inactiveColor,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
