import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  // Navigation:
  // 0 = Settings Main List
  // 1 = Privacy Policy
  // 2 = Terms & Conditions
  int _activeView = 0;

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

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            // In Light Mode: LIGHT.png
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
                      AppAssets.bgLight1,
                      fit: BoxFit.cover,
                    ),
            ),
            // Translucent cover
            Positioned.fill(
              child: Container(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.20)
                    : Colors.white.withValues(alpha: 0.20),
              ),
            ),

            // Navigation Screen Switcher
            SafeArea(
              bottom: false,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _buildActiveView(isDark, themeProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveView(bool isDark, ThemeProvider themeProvider) {
    switch (_activeView) {
      case 0:
        return _buildMainSettingsList(isDark, themeProvider);
      case 1:
        return _buildPrivacyPolicyView(isDark);
      case 2:
        return _buildTermsView(isDark);
      default:
        return _buildMainSettingsList(isDark, themeProvider);
    }
  }

  // ==========================================
  // VIEW 1: MAIN SETTINGS & CONTACT
  // ==========================================
  Widget _buildMainSettingsList(bool isDark, ThemeProvider themeProvider) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);

    return SingleChildScrollView(
      key: const ValueKey('settings_main'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Brand Logo Header
          Center(child: _buildBrandLogo(isDark)),
          const SizedBox(height: 28),

          // Section Title: APPEARANCE
          Text(
            'APPEARANCE',
            style: GoogleFonts.cinzel(
              color: goldColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              shadows: textShadows,
            ),
          ),
          const SizedBox(height: 12),

          // Theme Switcher Tile
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
            child: Row(
              children: [
                Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: isDark ? AppColors.goldLight : AppColors.goldPrimaryDark,
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDark ? 'Dark Theme Active' : 'Light Theme Active',
                        style: GoogleFonts.roboto(
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          shadows: textShadows,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDark ? 'Switch to radiant light cosmic theme' : 'Switch to deep space dark theme',
                        style: GoogleFonts.roboto(
                          color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                          fontSize: 11,
                          shadows: textShadows,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: !isDark,
                  activeThumbColor: AppColors.goldPrimaryDark,
                  activeTrackColor: const Color(0xFFFEA703).withValues(alpha: 0.35),
                  inactiveThumbColor: AppColors.goldPrimary,
                  inactiveTrackColor: Colors.white24,
                  onChanged: (bool value) {
                    themeProvider.setThemeMode(value ? ThemeMode.light : ThemeMode.dark);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section Title: CONTACT US
          Text(
            'CONTACT US',
            style: GoogleFonts.cinzel(
              color: goldColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              shadows: textShadows,
            ),
          ),
          const SizedBox(height: 12),

          // Contact Details Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
              children: [
                _buildContactItem(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: '+91 98765 43210',
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildContactItem(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: 'contact@astroramji.com',
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildContactItem(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: '123 Brahmin Colony, Varanasi, UP 221001',
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildContactItem(
                  icon: Icons.language_outlined,
                  label: 'Website',
                  value: 'www.Astroramji.com',
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Menu: Privacy Policy
          _buildActionMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we use your data',
            isDark: isDark,
            onTap: () => setState(() => _activeView = 1),
          ),
          const SizedBox(height: 12),

          // Action Menu: Terms & Conditions
          _buildActionMenuItem(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Usage guidelines',
            isDark: isDark,
            onTap: () => setState(() => _activeView = 2),
          ),
          const SizedBox(height: 12),

          // Action Menu: Sign Out
          _buildActionMenuItem(
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            subtitle: '',
            isSignOut: true,
            isDark: isDark,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: isDark ? AppColors.cardDark : AppColors.spaceLight,
                  content: Text(
                    'Signing out...',
                    style: GoogleFonts.roboto(color: goldColor),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Delete Account Button (Red)
          GestureDetector(
            onTap: () {
              _showDeleteConfirmationDialog(isDark);
            },
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF9E2A2B).withValues(alpha: isDark ? 0.85 : 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Delete Account',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
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

  // ==========================================
  // VIEW 2: PRIVACY POLICY VIEW
  // ==========================================
  Widget _buildPrivacyPolicyView(bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);

    return SingleChildScrollView(
      key: const ValueKey('privacy_policy'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSubHeaderRow(isDark),
          const SizedBox(height: 20),
          _buildDetailTitleBadge('PRIVACY POLICY', isDark),
          const SizedBox(height: 8),
          Text(
            'Last updated: August 2026',
            style: GoogleFonts.roboto(
              color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
              fontSize: 10,
              shadows: textShadows,
            ),
          ),
          const SizedBox(height: 8),
          Center(child: Text('✦', style: TextStyle(color: goldColor, fontSize: 16))),
          const SizedBox(height: 16),
          _buildPolicyParagraph(
            'Astro Ramji ("we", "our", "us") is committed to protecting your personal information and respecting your privacy. When you use our app, we collect information you provide directly — including your name, date of birth, time of birth, and place of birth — solely to generate accurate Kundali charts, planetary readings, and astrological compatibility results. We do not sell your personal data to third parties.',
            isDark,
          ),
          _buildPolicyParagraph(
            'Your data is stored on secured servers with encryption at rest and in transit, and is retained only for as long as your account remains active. You may request deletion of your data at any time through the Delete Account option in Settings. We may use anonymised, aggregated statistics to improve our astrological models and app performance.',
            isDark,
          ),
          _buildPolicyParagraph(
            'Astro Ramji may integrate with third-party services such as analytics or payment processors, each governed by their own privacy policies. All astrological interpretations are provided for informational and entertainment purposes based on classical Vedic astrology principles and should not be treated as professional advice.',
            isDark,
          ),
          _buildPolicyParagraph(
            'We may update this policy from time to time and will notify you of significant changes via in-app notification or email. Continued use of the app after changes constitutes acceptance of the updated policy. For privacy-related questions, contact us at contact@astroramji.com.',
            isDark,
          ),
          const SizedBox(height: 16),
          Center(child: Text('✦', style: TextStyle(color: goldColor, fontSize: 16))),
          const SizedBox(height: 12),
          Text(
            'WWW.ASTRORAMJI.COM',
            style: GoogleFonts.cinzel(
              color: isDark ? Colors.white54 : AppColors.textMutedLight,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              shadows: textShadows,
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 3: TERMS & CONDITIONS VIEW
  // ==========================================
  Widget _buildTermsView(bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);

    return SingleChildScrollView(
      key: const ValueKey('terms_and_conditions'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSubHeaderRow(isDark),
          const SizedBox(height: 20),
          _buildDetailTitleBadge('TERMS & CONDITIONS', isDark),
          const SizedBox(height: 8),
          Text(
            'Effective: August 2026',
            style: GoogleFonts.roboto(
              color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
              fontSize: 10,
              shadows: textShadows,
            ),
          ),
          const SizedBox(height: 8),
          Center(child: Text('✦', style: TextStyle(color: goldColor, fontSize: 16))),
          const SizedBox(height: 16),
          _buildPolicyParagraph(
            'By downloading or using Astro Ramji, you agree to be bound by these Terms and Conditions. Please read them carefully before using the app. If you do not agree with any part of these terms, you may not access or use our services.',
            isDark,
          ),
          _buildPolicyParagraph(
            'Astro Ramji grants you a limited, non-exclusive, non-transferable, revocable licence to use the app for personal, non-commercial purposes. You may not copy, modify, distribute, sell, or lease any part of our services or software. Reverse engineering or attempting to extract source code is strictly prohibited.',
            isDark,
          ),
          _buildPolicyParagraph(
            'You are responsible for maintaining the confidentiality of your account credentials. Any activity conducted through your account is your responsibility. Notify us immediately at contact@astroramji.com if you suspect any unauthorised access.',
            isDark,
          ),
          _buildPolicyParagraph(
            'All astrological readings, Kundali charts, and compatibility reports generated by Astro Ramji are provided for informational and entertainment purposes only. They are based on classical Vedic astrology traditions and do not constitute professional, medical, legal, or financial advice. Reliance on any such content is solely at your own discretion.',
            isDark,
          ),
          _buildPolicyParagraph(
            'Astro Ramji reserves the right to suspend or terminate accounts that violate these terms, engage in fraudulent activity, or misuse the platform. We may update these Terms at any time. Continued use of the app after any changes constitutes your acceptance of the revised terms.',
            isDark,
          ),
          const SizedBox(height: 16),
          Center(child: Text('✦', style: TextStyle(color: goldColor, fontSize: 16))),
          const SizedBox(height: 12),
          Text(
            'WWW.ASTRORAMJI.COM',
            style: GoogleFonts.cinzel(
              color: isDark ? Colors.white54 : AppColors.textMutedLight,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              shadows: textShadows,
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // --- Sub-widgets & Helpers ---
  Widget _buildBrandLogo(bool isDark) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 38,
          height: 38,
          child: Image.asset(
            AppAssets.rashiChakra,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.auto_awesome,
              color: goldColor,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ASTRO',
              style: GoogleFonts.cinzel(
                color: goldColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                shadows: textShadows,
              ),
            ),
            Text(
              'Ramji',
              style: GoogleFonts.cinzel(
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                shadows: textShadows,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubHeaderRow(bool isDark) {
    final goldColor = AppColors.getGold(isDark);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => setState(() => _activeView = 0),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
              border: Border.all(
                color: isDark ? Colors.white24 : goldColor.withValues(alpha: 0.4),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Icon(Icons.chevron_left_rounded, color: goldColor, size: 20),
            ),
          ),
        ),
        _buildBrandLogo(isDark),
        const SizedBox(width: 32),
      ],
    );
  }

  Widget _buildDetailTitleBadge(String title, bool isDark) {
    final goldColor = AppColors.getGold(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withValues(alpha: 0.5), width: 1.0),
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
      child: Text(
        title,
        style: GoogleFonts.cinzel(
          color: goldColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          shadows: AppColors.getTextShadows(isDark),
        ),
      ),
    );
  }

  Widget _buildPolicyParagraph(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          color: isDark ? Colors.white.withValues(alpha: 0.85) : AppColors.textPrimaryLight,
          fontSize: 12,
          height: 1.6,
          shadows: AppColors.getTextShadows(isDark),
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);
    final labelColor = isDark ? Colors.white60 : AppColors.textSecondaryLight;
    final valueColor = isDark ? Colors.white : AppColors.textPrimaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: goldColor, size: 18),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.roboto(
                    color: labelColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    shadows: textShadows,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.roboto(
                    color: valueColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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

  Widget _buildDivider(bool isDark) {
    return Divider(
      color: isDark ? Colors.white12 : const Color(0x20D4A827),
      height: 1,
      indent: 48,
    );
  }

  Widget _buildActionMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isSignOut = false,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final goldColor = AppColors.getGold(isDark);
    final textShadows = AppColors.getTextShadows(isDark);
    final titleColor = isSignOut
        ? const Color(0xFFCE7C2E)
        : (isDark ? Colors.white : AppColors.textPrimaryLight);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSignOut ? const Color(0xFFCE7C2E) : goldColor,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      color: titleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      shadows: textShadows,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.roboto(
                        color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                        fontSize: 11,
                        shadows: textShadows,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isSignOut)
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white54 : AppColors.textMutedLight,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          title: Text(
            'DELETE ACCOUNT',
            style: GoogleFonts.cinzel(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.0,
            ),
          ),
          content: Text(
            'Are you sure you want to permanently delete your account? This action cannot be undone.',
            style: GoogleFonts.roboto(
              color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: GoogleFonts.roboto(
                  color: isDark ? Colors.white60 : AppColors.textMutedLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text(
                      'Account deletion request submitted.',
                      style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
              child: Text(
                'DELETE',
                style: GoogleFonts.roboto(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
