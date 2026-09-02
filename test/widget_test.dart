import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astro_ramji/core/constants/app_colors.dart';
import 'package:astro_ramji/core/constants/app_assets.dart';
import 'package:astro_ramji/presentation/providers/theme_provider.dart';

void main() {
  test('ThemeProvider toggles dark and light mode correctly', () {
    final themeProvider = ThemeProvider();
    expect(themeProvider.isDarkMode, true);
    expect(themeProvider.isLightMode, false);

    themeProvider.toggleTheme();
    expect(themeProvider.isDarkMode, false);
    expect(themeProvider.isLightMode, true);

    themeProvider.setThemeMode(ThemeMode.dark);
    expect(themeProvider.isDarkMode, true);
    expect(themeProvider.isLightMode, false);
  });

  test('AppColors provides valid tokens for both dark and light modes', () {
    expect(AppColors.getBackground(true), AppColors.spaceDark);
    expect(AppColors.getBackground(false), AppColors.spaceLight);

    expect(AppColors.getTextPrimary(true), AppColors.textPrimary);
    expect(AppColors.getTextPrimary(false), AppColors.textPrimaryLight);

    expect(AppColors.getGold(true), AppColors.goldPrimary);
    expect(AppColors.getGold(false), AppColors.goldPrimaryDark);
  });

  test('AppAssets constants reference all light background assets', () {
    expect(AppAssets.bgLight1, 'assets/images/background/LIGHT.png');
    expect(AppAssets.bgLight2, 'assets/images/background/LIGHT2.png');
    expect(AppAssets.bgLight3, 'assets/images/background/LIGHT3.png');
    expect(AppAssets.bgLight4, 'assets/images/background/LIGHT4.png');
  });

  testWidgets('Theme toggle widget test', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Text(themeProvider.isLightMode ? 'LIGHT MODE' : 'DARK MODE');
            },
          ),
        ),
      ),
    );

    expect(find.text('DARK MODE'), findsOneWidget);

    themeProvider.toggleTheme();
    await tester.pump();
  });
}
