import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/custom_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background/getstartedbg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
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
                      'assets/images/logo/getstartedlogo.png',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    const Spacer(),
                    // Title
                    Text(
                      'DISCOVER YOUR\nCOSMIC BLUEPRINT',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headline.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Description
                    Text(
                      'Generate your natal birth chart, explore planetary positions, and find cosmic compatibility with your partner.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subheadline.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    // Buttons
                    CustomButton(
                      text: 'GET STARTED',
                      onPressed: () {
                        context.push('/auth');
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'I already have an account',
                      isGradient: false,
                      onPressed: () {
                        context.push('/auth');
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
