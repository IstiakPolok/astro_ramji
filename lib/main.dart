import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_colors.dart';
import 'core/localization/app_localizations.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/language_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp.router(
      title: 'Astro Ramji',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      locale: languageProvider.currentLocale,
      supportedLocales: LanguageProvider.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.spaceLight,
        primaryColor: AppColors.goldPrimaryDark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.goldPrimary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.spaceDark,
        primaryColor: AppColors.goldPrimary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.goldPrimary,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
