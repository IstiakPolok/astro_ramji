import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isGradient;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isGradient = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = 56.0;
    final buttonWidth = 335.0;
    final borderRadius = BorderRadius.circular(16);
    const gradient = AppColors.buttonGradient;
    final shadow = [
      BoxShadow(
        color: AppColors.buttonShadow,
        blurRadius: 24,
        offset: const Offset(0, 6),
      ),
    ];

    if (isLoading) {
      return Center(
        child: Container(
          height: buttonHeight,
          width: buttonWidth,
          alignment: Alignment.center,
          decoration: isGradient
              ? BoxDecoration(
                  gradient: gradient,
                  borderRadius: borderRadius,
                  boxShadow: shadow,
                )
              : BoxDecoration(
                  border: Border.all(color: AppColors.borderDark, width: 1.5),
                  borderRadius: borderRadius,
                ),
          child: const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (isGradient) {
      return Center(
        child: Container(
          height: buttonHeight,
          width: buttonWidth,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: borderRadius,
            boxShadow: shadow,
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
            ),
            onPressed: onPressed,
            child: Text(text, style: AppTextStyles.buttonText),
          ),
        ),
      );
    } else {
      return Center(
        child: SizedBox(
          height: buttonHeight,
          width: buttonWidth,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: AppColors.goldPrimary.withValues(alpha: 0.3),
                width: 1.5,
              ),

              shape: RoundedRectangleBorder(borderRadius: borderRadius),
            ),
            onPressed: onPressed,
            child: Text(
              text,
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.goldPrimary,
              ),
            ),
          ),
        ),
      );
    }
  }
}
