import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  static const String _prefKey = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  SharedPreferences? _prefs;
  Future<void>? _initFuture;
  bool _hasUserSetMode = false;

  ThemeProvider() {
    WidgetsBinding.instance.addObserver(this);
    init();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  /// Returns true if the active appearance is dark mode.
  /// When themeMode is system, it dynamically checks the device's platform brightness.
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  bool get isLightMode => !isDarkMode;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Loads saved theme preference from SharedPreferences.
  /// Defaults to ThemeMode.system (device preference) if no preference was set.
  Future<void> init() {
    _initFuture ??= _loadFromPrefs();
    return _initFuture!;
  }

  Future<void> _loadFromPrefs() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      if (!_hasUserSetMode) {
        final savedMode = _prefs!.getString(_prefKey);
        if (savedMode != null) {
          switch (savedMode) {
            case 'dark':
              _themeMode = ThemeMode.dark;
              break;
            case 'light':
              _themeMode = ThemeMode.light;
              break;
            case 'system':
            default:
              _themeMode = ThemeMode.system;
              break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Sets the theme mode explicitly (system, dark, or light) and persists the choice.
  Future<void> setThemeMode(ThemeMode mode) async {
    _hasUserSetMode = true;
    _themeMode = mode;
    notifyListeners();

    try {
      _prefs ??= await SharedPreferences.getInstance();
      switch (mode) {
        case ThemeMode.dark:
          await _prefs!.setString(_prefKey, 'dark');
          break;
        case ThemeMode.light:
          await _prefs!.setString(_prefKey, 'light');
          break;
        case ThemeMode.system:
          await _prefs!.setString(_prefKey, 'system');
          break;
      }
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  /// Toggles between light and dark themes.
  /// If currently following system, toggles to the opposite of current device brightness.
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.system) {
      final currentIsDark =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark;
      await setThemeMode(currentIsDark ? ThemeMode.light : ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  @override
  void didChangePlatformBrightness() {
    // When following system preference, re-render whenever the device switches dark/light mode
    if (_themeMode == ThemeMode.system) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
