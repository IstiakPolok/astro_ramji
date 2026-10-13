import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:astro_ramji/core/constants/app_colors.dart';
import 'package:astro_ramji/core/constants/app_assets.dart';
import 'package:astro_ramji/core/localization/app_localizations.dart';
import 'package:astro_ramji/presentation/providers/theme_provider.dart';
import 'package:astro_ramji/presentation/providers/language_provider.dart';
import 'package:astro_ramji/presentation/widgets/theme_picker_sheet.dart';
import 'package:astro_ramji/presentation/pages/splash/splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ThemeProvider starts with system device preference and allows custom selection', () async {
    final themeProvider = ThemeProvider();
    await themeProvider.init();

    // Default is ThemeMode.system (Device preference)
    expect(themeProvider.themeMode, ThemeMode.system);
    expect(themeProvider.isSystemMode, true);

    // Explicitly set Dark Mode
    await themeProvider.setThemeMode(ThemeMode.dark);
    expect(themeProvider.themeMode, ThemeMode.dark);
    expect(themeProvider.isDarkMode, true);
    expect(themeProvider.isLightMode, false);
    expect(themeProvider.isSystemMode, false);

    // Explicitly set Light Mode
    await themeProvider.setThemeMode(ThemeMode.light);
    expect(themeProvider.themeMode, ThemeMode.light);
    expect(themeProvider.isDarkMode, false);
    expect(themeProvider.isLightMode, true);
    expect(themeProvider.isSystemMode, false);

    // Switch back to System (Device preference)
    await themeProvider.setThemeMode(ThemeMode.system);
    expect(themeProvider.themeMode, ThemeMode.system);
    expect(themeProvider.isSystemMode, true);
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

  test('ThemeProvider restores persisted theme mode from SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({'app_theme_mode': 'light'});
    final themeProvider = ThemeProvider();
    await themeProvider.init();

    expect(themeProvider.themeMode, ThemeMode.light);
    expect(themeProvider.isLightMode, true);
    expect(themeProvider.isDarkMode, false);
    expect(themeProvider.isSystemMode, false);
  });

  test('AppLocalizations translates theme keys accurately for all 5 languages', () {
    final locEn = AppLocalizations(const Locale('en'));
    final locHi = AppLocalizations(const Locale('hi'));
    final locTa = AppLocalizations(const Locale('ta'));
    final locTe = AppLocalizations(const Locale('te'));
    final locKn = AppLocalizations(const Locale('kn'));

    // English
    expect(locEn.translate('theme_mode_system'), 'Device Preference (System)');
    expect(locEn.translate('theme_mode_dark'), 'Dark Mode');
    expect(locEn.translate('theme_mode_light'), 'Light Mode');
    expect(locEn.translate('select_theme'), 'Select Theme');

    // Hindi
    expect(locHi.translate('theme_mode_system'), 'डिवाइस प्राथमिकता (सिस्टम)');
    expect(locHi.translate('theme_mode_dark'), 'डार्क मोड');
    expect(locHi.translate('theme_mode_light'), 'लाइट मोड');
    expect(locHi.translate('select_theme'), 'थीम चुनें');

    // Tamil
    expect(locTa.translate('theme_mode_system'), 'சாதன விருப்பம் (கணினி)');
    expect(locTa.translate('theme_mode_dark'), 'டார்க் மோட்');
    expect(locTa.translate('theme_mode_light'), 'லைட் மோட்');
    expect(locTa.translate('select_theme'), 'தீமைத் தேர்ந்தெடுக்கவும்');

    // Telugu
    expect(locTe.translate('theme_mode_system'), 'పరికర ప్రాధాన్యత (సిస్టమ్)');
    expect(locTe.translate('theme_mode_dark'), 'డార్క్ మోడ్');
    expect(locTe.translate('theme_mode_light'), 'లైట్ మోడ్');
    expect(locTe.translate('select_theme'), 'థీమ్‌ను ఎంచుకోండి');

    // Kannada
    expect(locKn.translate('theme_mode_system'), 'ಸಾಧನದ ಆದ್ಯತೆ (ಸಿಸ್ಟಮ್)');
    expect(locKn.translate('theme_mode_dark'), 'ಡಾರ್ಕ್ ಮೋಡ್');
    expect(locKn.translate('theme_mode_light'), 'ಲೈಟ್ ಮೋಡ್');
    expect(locKn.translate('select_theme'), 'ಥೀಮ್ ಆಯ್ಕೆಮಾಡಿ');
  });

  testWidgets('ThemePickerSheet opens and switches theme mode', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();
    await themeProvider.init();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: themeProvider,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => showThemePickerSheet(context, themeProvider.isDarkMode),
                  child: const Text('Open Theme Picker'),
                );
              },
            ),
          ),
        ),
      ),
    );

    // Initial mode is system
    expect(themeProvider.themeMode, ThemeMode.system);

    // Tap button to open sheet
    await tester.tap(find.text('Open Theme Picker'));
    await tester.pumpAndSettle();

    // Verify sheet title and options are visible
    expect(find.text('Select Theme'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('Light Mode'), findsOneWidget);

    // Tap Dark Mode
    await tester.tap(find.text('Dark Mode'));
    await tester.pumpAndSettle();

    // Verify theme mode switched to dark
    expect(themeProvider.themeMode, ThemeMode.dark);
    expect(themeProvider.isDarkMode, true);
  });

  testWidgets('SplashPage displays saved dark theme on startup', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'app_theme_mode': 'dark'});
    final themeProvider = ThemeProvider();
    await themeProvider.init();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: themeProvider,
        child: const MaterialApp(
          home: SplashPage(),
        ),
      ),
    );

    // Verify dark mode is active and dark background color is rendered
    expect(themeProvider.isDarkMode, true);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppColors.spaceDark);

    // Unmount widget to trigger dispose and timer cleanup
    await tester.pumpWidget(const SizedBox());
  });
}
