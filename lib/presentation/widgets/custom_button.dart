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
    final buttonHeight = 54.0;
    
    if (isLoading) {
      return Container(
        height: buttonHeight,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: isGradient
            ? BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(27),
              )
            : BoxDecoration(
                border: Border.all(color: AppColors.borderDark, width: 1.5),
                borderRadius: BorderRadius.circular(27),
              ),
        child: const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.black,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (isGradient) {
      return Container(
        height: buttonHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: AppColors.goldPrimary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: AppTextStyles.buttonText,
          ),
        ),
      );
    } else {
      return SizedBox(
        height: buttonHeight,
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.borderDark, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: AppTextStyles.buttonText.copyWith(color: AppColors.textPrimary),
          ),
        ),
      );
    }
  }
}
