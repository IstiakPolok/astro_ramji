import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _currentStep = 0; // 0: Request OTP, 1: Verify OTP, 2: Create Password, 3: Success

  // Step 0: Request OTP
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // Step 1: Verify OTP
  final List<TextEditingController> _otpControllers = List.generate(5, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(5, (_) => FocusNode());
  int _resendTimerSeconds = 12;
  Timer? _timer;

  // Step 2: Create Password
  final _passwordFormKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _resendTimerSeconds = 12;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimerSeconds > 0) {
        setState(() {
          _resendTimerSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
    if (_currentStep == 1) {
      _startTimer();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: Stack(
        children: [
          if (!isDark)
            Positioned.fill(
              child: Image.asset(
                AppAssets.bgLight1,
                fit: BoxFit.cover,
              ),
            ),
          if (!isDark)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          // Watermark Om Symbol in background
          Positioned.fill(
            child: Align(
              alignment: const Alignment(0.0, 0.7),
              child: Opacity(
                opacity: isDark ? 0.05 : 0.07,
                child: Text(
                  'ॐ',
                  style: GoogleFonts.cinzel(
                    fontSize: 320,
                    color: AppColors.getGold(isDark),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button (hidden in success step)
                    if (_currentStep < 3)
                      IconButton(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.zero,
                        onPressed: _prevStep,
                        icon: Icon(
                          Icons.chevron_left,
                          color: AppColors.getGold(isDark),
                          size: 36,
                        ),
                      )
                    else
                      const SizedBox(height: 48),
                    const SizedBox(height: 24),

                    // Render Step Content
                    if (_currentStep == 0)
                      _buildForgetPasswordStep(isDark)
                    else if (_currentStep == 1)
                      _buildVerificationStep(isDark)
                    else if (_currentStep == 2)
                      _buildCreatePasswordStep(isDark)
                    else
                      _buildSuccessStep(isDark),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 0: Forget Password ---
  Widget _buildForgetPasswordStep(bool isDark) {
    final textPrimary = isDark ? Colors.white : AppColors.textPrimaryLight;

    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FORGET PASSWORD',
            style: GoogleFonts.cinzel(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 36),
          CustomTextField(
            label: 'Email',
            hintText: 'you@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.isEmpty || !val.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 36),
          CustomButton(
            text: 'REQUEST OTP \u2794',
            onPressed: () {
              if (_emailFormKey.currentState!.validate()) {
                _nextStep();
              }
            },
          ),
        ],
      ),
    );
  }

  // --- Step 1: Verification / Enter OTP ---
  Widget _buildVerificationStep(bool isDark) {
    final textPrimary = isDark ? Colors.white : AppColors.textPrimaryLight;
    final goldColor = AppColors.getGold(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VERIFICATION',
          style: GoogleFonts.cinzel(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 36),
        Text(
          'ENTER OTP',
          style: GoogleFonts.cinzel(
            color: goldColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        // 5 OTP Box Inputs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            return SizedBox(
              width: 54,
              height: 54,
              child: TextFormField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: GoogleFonts.roboto(
                  color: textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  fillColor: isDark ? AppColors.cardDark : Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.borderDark : const Color(0x35D4A827),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: goldColor,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 4) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 36),
        CustomButton(
          text: 'ENTER \u2794',
          onPressed: _nextStep,
        ),
        const SizedBox(height: 24),
        Center(
          child: _resendTimerSeconds > 0
              ? Text(
                  'RESEND OTP (00:${_resendTimerSeconds.toString().padLeft(2, '0')})',
                  style: GoogleFonts.roboto(
                    color: AppColors.getTextMuted(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : TextButton(
                  onPressed: _startTimer,
                  child: Text(
                    'RESEND OTP',
                    style: GoogleFonts.roboto(
                      color: AppColors.goldOrange,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // --- Step 2: Create New Password ---
  Widget _buildCreatePasswordStep(bool isDark) {
    final textPrimary = isDark ? Colors.white : AppColors.textPrimaryLight;

    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CREATE NEW PASSWORD',
            style: GoogleFonts.cinzel(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 36),
          CustomTextField(
            label: 'New Password',
            hintText: '••••••••',
            controller: _passwordController,
            obscureText: true,
            validator: (val) {
              if (val == null || val.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Confirm Password',
            hintText: '••••••••',
            controller: _confirmPasswordController,
            obscureText: true,
            validator: (val) {
              if (val != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 36),
          CustomButton(
            text: 'VERIFY \u2794',
            onPressed: () {
              if (_passwordFormKey.currentState!.validate()) {
                _nextStep();
              }
            },
          ),
        ],
      ),
    );
  }

  // --- Step 3: Success Screen ---
  Widget _buildSuccessStep(bool isDark) {
    final textPrimary = isDark ? Colors.white : AppColors.textPrimaryLight;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'PASSWORD CHANGED',
            style: GoogleFonts.cinzel(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 50),
          // Shield Verified Icon matching the mockup
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: isDark ? 0.15 : 0.12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Colors.green,
              size: 80,
            ),
          ),
          const SizedBox(height: 36),
          Text(
            'Password Changed!',
            style: GoogleFonts.roboto(
              color: textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your password has been\nchanged successfully.',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: AppColors.getTextSecondary(isDark),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 48),
          CustomButton(
            text: 'HOME \u2794',
            onPressed: () {
              context.go('/auth?tab=login');
            },
          ),
        ],
      ),
    );
  }
}
