import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'home/home_page.dart';
import 'kundali/kundali_form_screen.dart';
import 'matching/matching_screen.dart';
import 'settings/settings_screen.dart';

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
    const Scaffold(
      backgroundColor: AppColors.spaceDark,
      body: Center(
        child: Text(
          'FORECAST/SUN ACTION SCREEN',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    ),
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
    return Scaffold(
      backgroundColor: AppColors.spaceDark,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      color: const Color(0xE505030A), // slightly transparent dark overlay
      child: SafeArea(
        top: false,
        bottom: true,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, 'HOME'),
              _buildNavItem(1, Icons.auto_awesome_outlined, 'KUNDALI'),

              // Glowing Floating center sun button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = 2; // Middle index
                  });
                },
                child: Transform.translate(
                  offset: const Offset(0, -10),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.goldPrimary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldPrimary.withValues(alpha: 0.4),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.wb_sunny_rounded,
                      color: _currentIndex == 2
                          ? AppColors.goldOrange
                          : AppColors.goldPrimary,
                      size: 28,
                    ),
                  ),
                ),
              ),

              _buildNavItem(3, Icons.favorite_border_rounded, 'MATCHING'),
              _buildNavItem(4, Icons.person_outline_rounded, 'ACCOUNT'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
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
            color: isSelected ? AppColors.goldPrimary : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.cinzel(
              color: isSelected
                  ? AppColors.goldPrimary
                  : AppColors.textSecondary,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
