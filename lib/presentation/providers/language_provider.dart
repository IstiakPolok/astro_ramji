import 'package:flutter/material.dart';

class LanguageInfo {
  final String code;
  final String nativeName;
  final String englishName;
  final String scriptSymbol;

  const LanguageInfo({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.scriptSymbol,
  });
}

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;

  static const List<LanguageInfo> supportedLanguages = [
    LanguageInfo(
      code: 'en',
      nativeName: 'English',
      englishName: 'English',
      scriptSymbol: 'En',
    ),
    LanguageInfo(
      code: 'hi',
      nativeName: 'हिन्दी',
      englishName: 'Hindi',
      scriptSymbol: 'अ',
    ),
    LanguageInfo(
      code: 'ta',
      nativeName: 'தமிழ்',
      englishName: 'Tamil',
      scriptSymbol: 'த',
    ),
    LanguageInfo(
      code: 'te',
      nativeName: 'తెలుగు',
      englishName: 'Telugu',
      scriptSymbol: 'తె',
    ),
    LanguageInfo(
      code: 'kn',
      nativeName: 'ಕನ್ನಡ',
      englishName: 'Kannada (Karnataka)',
      scriptSymbol: 'ಕ',
    ),
  ];

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('ta'),
    Locale('te'),
    Locale('kn'),
  ];

  String get currentLanguageName {
    final match = supportedLanguages.firstWhere(
      (l) => l.code == _currentLocale.languageCode,
      orElse: () => supportedLanguages.first,
    );
    return match.nativeName;
  }

  void setLocale(Locale locale) {
    if (_currentLocale == locale) return;
    _currentLocale = locale;
    notifyListeners();
  }

  void setLanguageCode(String code) {
    if (_currentLocale.languageCode == code) return;
    _currentLocale = Locale(code);
    notifyListeners();
  }
}
