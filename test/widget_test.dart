import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:astro_ramji/core/constants/app_colors.dart';
import 'package:astro_ramji/core/constants/app_assets.dart';
import 'package:astro_ramji/core/localization/app_localizations.dart';
import 'package:astro_ramji/presentation/providers/theme_provider.dart';
import 'package:astro_ramji/presentation/providers/language_provider.dart';

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

  test('LanguageProvider supports English, Hindi, Tamil, Telugu, and Kannada', () {
    final languageProvider = LanguageProvider();
    expect(languageProvider.currentLanguageCode, 'en');
    expect(languageProvider.currentLanguageName, 'English');

    // Hindi
    languageProvider.setLanguageCode('hi');
    expect(languageProvider.currentLanguageCode, 'hi');
    expect(languageProvider.currentLanguageName, 'हिन्दी');

    // Tamil
    languageProvider.setLanguageCode('ta');
    expect(languageProvider.currentLanguageCode, 'ta');
    expect(languageProvider.currentLanguageName, 'தமிழ்');

    // Telugu
    languageProvider.setLanguageCode('te');
    expect(languageProvider.currentLanguageCode, 'te');
    expect(languageProvider.currentLanguageName, 'తెలుగు');

    // Kannada (Karnataka)
    languageProvider.setLanguageCode('kn');
    expect(languageProvider.currentLanguageCode, 'kn');
    expect(languageProvider.currentLanguageName, 'ಕನ್ನಡ');
  });

  test('AppLocalizations translates keys accurately for all 5 languages', () {
    final locEn = AppLocalizations(const Locale('en'));
    final locHi = AppLocalizations(const Locale('hi'));
    final locTa = AppLocalizations(const Locale('ta'));
    final locTe = AppLocalizations(const Locale('te'));
    final locKn = AppLocalizations(const Locale('kn'));

    // Navigation Home
    expect(locEn.translate('nav_home'), 'HOME');
    expect(locHi.translate('nav_home'), 'होम');
    expect(locTa.translate('nav_home'), 'முகப்பு');
    expect(locTe.translate('nav_home'), 'హోమ్');
    expect(locKn.translate('nav_home'), 'ಮುಖಪುಟ');

    // Kundali Title
    expect(locEn.translate('birth_details_title'), 'BIRTH DETAILS');
    expect(locHi.translate('birth_details_title'), 'जन्म विवरण');
    expect(locTa.translate('birth_details_title'), 'பிறப்பு விவரங்கள்');
    expect(locTe.translate('birth_details_title'), 'జన్మ వివరాలు');
    expect(locKn.translate('birth_details_title'), 'ಜನನ ವಿವರಗಳು');

    // Daily Horoscope
    expect(locEn.translate('daily_horoscope'), 'DAILY HOROSCOPE');
    expect(locHi.translate('daily_horoscope'), 'दैनिक राशिफल');
    expect(locTa.translate('daily_horoscope'), 'தினசரி ராசிபலன்');
    expect(locTe.translate('daily_horoscope'), 'దిన రాశిఫలాలు');
    expect(locKn.translate('daily_horoscope'), 'ದಿನ ಭವಿಷ್ಯ');

    // Kundali Matching
    expect(locEn.translate('kundali_matching'), 'KUNDALI MATCHING');
    expect(locHi.translate('kundali_matching'), 'कुंडली मिलान');
    expect(locTa.translate('kundali_matching'), 'திருமணப் பொருத்தம்');
    expect(locTe.translate('kundali_matching'), 'గుణమేళనం');
    expect(locKn.translate('kundali_matching'), 'ಜಾತಕ ಹೊಂದಾಣಿಕೆ');
  });

  testWidgets('App dynamic language switching in widget tree', (WidgetTester tester) async {
    final languageProvider = LanguageProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: languageProvider,
        child: Consumer<LanguageProvider>(
          builder: (context, lang, child) {
            return MaterialApp(
              locale: lang.currentLocale,
              supportedLocales: LanguageProvider.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Builder(
                builder: (context) {
                  return Scaffold(
                    body: Text(context.tr('nav_home')),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    // Initial English
    expect(find.text('HOME'), findsOneWidget);

    // Switch to Hindi
    languageProvider.setLanguageCode('hi');
    await tester.pumpAndSettle();
    expect(find.text('होम'), findsOneWidget);

    // Switch to Tamil
    languageProvider.setLanguageCode('ta');
    await tester.pumpAndSettle();
    expect(find.text('முகப்பு'), findsOneWidget);

    // Switch to Telugu
    languageProvider.setLanguageCode('te');
    await tester.pumpAndSettle();
    expect(find.text('హోమ్'), findsOneWidget);

    // Switch to Kannada (Karnataka)
    languageProvider.setLanguageCode('kn');
    await tester.pumpAndSettle();
    expect(find.text('ಮುಖಪುಟ'), findsOneWidget);
  });
}
