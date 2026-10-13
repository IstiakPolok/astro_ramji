import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              isDark ? AppAssets.bgGetStartedDark : AppAssets.bgLight1,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Light mode subtle tint overlay
            if (!isDark)
              Positioned.fill(
                child: Container(color: Colors.white.withValues(alpha: 0.25)),
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 24.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Om logo in golden circle
                    Image.asset(
                      AppAssets.getStartedLogo,
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    const Spacer(),
                    // Title
                    Text(
                      context.tr('discover_cosmic'),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headline.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Description
                    Text(
                      context.tr('welcome_sub'),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subheadline.copyWith(
                        color: AppColors.getTextSecondary(isDark),
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    // Buttons
                    CustomButton(
                      text: context.tr('get_started'),
                      onPressed: () {
                        context.go('/home');
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: context.tr('already_have_account'),
                      isGradient: false,
                      onPressed: () {
                        context.go('/home');
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
