import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';

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

  static const List<Shadow> _textShadows = [
    Shadow(
      color: Colors.black,
      blurRadius: 4,
      offset: Offset(1, 1),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/homescreenbg.mp4')
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
    return Scaffold(
      backgroundColor: AppColors.spaceDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Video
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
            // Translucent dark cover
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.2)),
            ),

            // Navigation Screen Switcher
            SafeArea(
              bottom: false,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _buildActiveView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveView() {
    switch (_activeView) {
      case 0:
        return _buildMainSettingsList();
      case 1:
        return _buildPrivacyPolicyView();
      case 2:
        return _buildTermsView();
      default:
        return _buildMainSettingsList();
    }
  }

  // ==========================================
  // VIEW 1: MAIN SETTINGS & CONTACT
  // ==========================================
  Widget _buildMainSettingsList() {
    return SingleChildScrollView(
      key: const ValueKey('settings_main'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Brand Logo Header
          Center(child: _buildBrandLogo()),
          const SizedBox(height: 32),

          // Section Title: CONTACT US
          Text(
            'CONTACT US',
            style: GoogleFonts.cinzel(
              color: AppColors.goldPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              shadows: _textShadows,
            ),
          ),
          const SizedBox(height: 12),

          // Contact Details Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 1.0),
            ),
            child: Column(
              children: [
                _buildContactItem(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: '+91 98765 43210',
                ),
                _buildDivider(),
                _buildContactItem(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: 'contact@astroramji.com',
                ),
                _buildDivider(),
                _buildContactItem(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: '123 Brahmin Colony, Varanasi, UP 221001',
                ),
                _buildDivider(),
                _buildContactItem(
                  icon: Icons.language_outlined,
                  label: 'Website',
                  value: 'www.Astroramji.com',
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
            onTap: () => setState(() => _activeView = 1),
          ),
          const SizedBox(height: 12),

          // Action Menu: Terms & Conditions
          _buildActionMenuItem(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Usage guidelines',
            onTap: () => setState(() => _activeView = 2),
          ),
          const SizedBox(height: 12),

          // Action Menu: Sign Out
          _buildActionMenuItem(
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            subtitle: '',
            isSignOut: true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.cardDark,
                  content: Text(
                    'Signing out...',
                    style: GoogleFonts.roboto(color: AppColors.goldPrimary),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Delete Account Button (Red)
          GestureDetector(
            onTap: () {
              _showDeleteConfirmationDialog();
            },
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF9E2A2B).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5), width: 1.0),
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
  Widget _buildPrivacyPolicyView() {
    return SingleChildScrollView(
      key: const ValueKey('privacy_policy'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSubHeaderRow(),
          const SizedBox(height: 20),
          _buildDetailTitleBadge('PRIVACY POLICY'),
          const SizedBox(height: 8),
          Text(
            'Last updated: August 2026',
            style: GoogleFonts.roboto(
              color: Colors.white70,
              fontSize: 10,
              shadows: _textShadows,
            ),
          ),
          const SizedBox(height: 8),
          const Center(child: Text('✦', style: TextStyle(color: AppColors.goldPrimary, fontSize: 16))),
          const SizedBox(height: 16),
          _buildPolicyParagraph(
            'Astro Ramji ("we", "our", "us") is committed to protecting your personal information and respecting your privacy. When you use our app, we collect information you provide directly — including your name, date of birth, time of birth, and place of birth — solely to generate accurate Kundali charts, planetary readings, and astrological compatibility results. We do not sell your personal data to third parties.',
          ),
          _buildPolicyParagraph(
            'Your data is stored on secured servers with encryption at rest and in transit, and is retained only for as long as your account remains active. You may request deletion of your data at any time through the Delete Account option in Settings. We may use anonymised, aggregated statistics to improve our astrological models and app performance.',
          ),
          _buildPolicyParagraph(
            'Astro Ramji may integrate with third-party services such as analytics or payment processors, each governed by their own privacy policies. All astrological interpretations are provided for informational and entertainment purposes based on classical Vedic astrology principles and should not be treated as professional advice.',
          ),
          _buildPolicyParagraph(
            'We may update this policy from time to time and will notify you of significant changes via in-app notification or email. Continued use of the app after changes constitutes acceptance of the updated policy. For privacy-related questions, contact us at contact@astroramji.com.',
          ),
          const SizedBox(height: 16),
          const Center(child: Text('✦', style: TextStyle(color: AppColors.goldPrimary, fontSize: 16))),
          const SizedBox(height: 12),
          Text(
            'WWW.ASTRORAMJI.COM',
            style: GoogleFonts.cinzel(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              shadows: _textShadows,
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
  Widget _buildTermsView() {
    return SingleChildScrollView(
      key: const ValueKey('terms_and_conditions'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSubHeaderRow(),
          const SizedBox(height: 20),
          _buildDetailTitleBadge('TERMS & CONDITIONS'),
          const SizedBox(height: 8),
          Text(
            'Effective: August 2026',
            style: GoogleFonts.roboto(
              color: Colors.white70,
              fontSize: 10,
              shadows: _textShadows,
            ),
          ),
          const SizedBox(height: 8),
          const Center(child: Text('✦', style: TextStyle(color: AppColors.goldPrimary, fontSize: 16))),
          const SizedBox(height: 16),
          _buildPolicyParagraph(
            'By downloading or using Astro Ramji, you agree to be bound by these Terms and Conditions. Please read them carefully before using the app. If you do not agree with any part of these terms, you may not access or use our services.',
          ),
          _buildPolicyParagraph(
            'Astro Ramji grants you a limited, non-exclusive, non-transferable, revocable licence to use the app for personal, non-commercial purposes. You may not copy, modify, distribute, sell, or lease any part of our services or software. Reverse engineering or attempting to extract source code is strictly prohibited.',
          ),
          _buildPolicyParagraph(
            'You are responsible for maintaining the confidentiality of your account credentials. Any activity conducted through your account is your responsibility. Notify us immediately at contact@astroramji.com if you suspect any unauthorised access.',
          ),
          _buildPolicyParagraph(
            'All astrological readings, Kundali charts, and compatibility reports generated by Astro Ramji are provided for informational and entertainment purposes only. They are based on classical Vedic astrology traditions and do not constitute professional, medical, legal, or financial advice. Reliance on any such content is solely at your own discretion.',
          ),
          _buildPolicyParagraph(
            'Astro Ramji reserves the right to suspend or terminate accounts that violate these terms, engage in fraudulent activity, or misuse the platform. We may update these Terms at any time. Continued use of the app after any changes constitutes your acceptance of the revised terms.',
          ),
          const SizedBox(height: 16),
          const Center(child: Text('✦', style: TextStyle(color: AppColors.goldPrimary, fontSize: 16))),
          const SizedBox(height: 12),
          Text(
            'WWW.ASTRORAMJI.COM',
            style: GoogleFonts.cinzel(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              shadows: _textShadows,
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // --- Sub-widgets & Helpers ---
  Widget _buildBrandLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 38,
          height: 38,
          child: Image.asset(
            'assets/images/Component/rashichakra.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.auto_awesome,
              color: AppColors.goldPrimary,
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
                color: AppColors.goldPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                shadows: _textShadows,
              ),
            ),
            Text(
              'Ramji',
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
                shadows: _textShadows,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubHeaderRow() {
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
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white24, width: 1.0),
            ),
            child: const Center(
              child: Icon(Icons.chevron_left_rounded, color: AppColors.goldPrimary, size: 20),
            ),
          ),
        ),
        _buildBrandLogo(),
        const SizedBox(width: 32), // spacer balance
      ],
    );
  }

  Widget _buildDetailTitleBadge(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4), width: 1.0),
      ),
      child: Text(
        title,
        style: GoogleFonts.cinzel(
          color: AppColors.goldPrimary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          shadows: _textShadows,
        ),
      ),
    );
  }

  Widget _buildPolicyParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 12,
          height: 1.6,
          shadows: _textShadows,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildContactItem({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.goldPrimary, size: 18),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.roboto(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    shadows: _textShadows,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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

  Widget _buildDivider() {
    return const Divider(
      color: Colors.white12,
      height: 1,
      indent: 48,
    );
  }

  Widget _buildActionMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isSignOut = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24, width: 1.0),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSignOut ? const Color(0xFFCE7C2E) : AppColors.goldPrimary,
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
                      color: isSignOut ? const Color(0xFFCE7C2E) : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      shadows: _textShadows,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.roboto(
                        color: Colors.white54,
                        fontSize: 11,
                        shadows: _textShadows,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isSignOut)
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white54,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardDark,
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
            style: GoogleFonts.roboto(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: GoogleFonts.roboto(color: Colors.white60, fontWeight: FontWeight.bold),
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
