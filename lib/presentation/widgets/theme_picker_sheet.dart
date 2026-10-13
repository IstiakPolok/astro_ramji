import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../providers/theme_provider.dart';

/// Shows the cosmic theme selection modal bottom sheet.
void showThemePickerSheet(BuildContext context, bool isDark) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Consumer<ThemeProvider>(
        builder: (context, provider, _) {
          final currentMode = provider.themeMode;
          final dynamicIsDark = provider.isDarkMode;
          final goldColor = AppColors.getGold(dynamicIsDark);

          final isDeviceDark =
              WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                  Brightness.dark;
          final deviceStatus = isDeviceDark
              ? context.tr('theme_mode_dark')
              : context.tr('theme_mode_light');

          final options = [
            _ThemeOption(
              mode: ThemeMode.system,
              title: context.tr('theme_mode_system'),
              subtitle:
                  '${context.tr('theme_desc_system')} ($deviceStatus)',
              icon: Icons.brightness_auto_rounded,
            ),
            _ThemeOption(
              mode: ThemeMode.dark,
              title: context.tr('theme_mode_dark'),
              subtitle: context.tr('theme_desc_light'),
              icon: Icons.dark_mode_rounded,
            ),
            _ThemeOption(
              mode: ThemeMode.light,
              title: context.tr('theme_mode_light'),
              subtitle: context.tr('theme_desc_dark'),
              icon: Icons.light_mode_rounded,
            ),
          ];

          return Container(
            decoration: BoxDecoration(
              color: dynamicIsDark ? AppColors.spaceDark : AppColors.spaceLight,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(color: goldColor, width: 1.5),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr('select_theme'),
                  style: GoogleFonts.cinzel(
                    color: goldColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final isSelected = currentMode == option.mode;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? goldColor.withValues(alpha: 0.2)
                                : (dynamicIsDark
                                    ? Colors.white12
                                    : const Color(0x20D4A827)),
                            border: Border.all(
                              color: isSelected
                                  ? goldColor
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              option.icon,
                              color: isSelected
                                  ? goldColor
                                  : (dynamicIsDark
                                      ? Colors.white
                                      : AppColors.textPrimaryLight),
                              size: 20,
                            ),
                          ),
                        ),
                        title: Text(
                          option.title,
                          style: GoogleFonts.roboto(
                            color: isSelected
                                ? goldColor
                                : (dynamicIsDark
                                    ? Colors.white
                                    : AppColors.textPrimaryLight),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          option.subtitle,
                          style: GoogleFonts.roboto(
                            color: dynamicIsDark
                                ? Colors.white54
                                : AppColors.textSecondaryLight,
                            fontSize: 12,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle_rounded, color: goldColor)
                            : null,
                        onTap: () {
                          provider.setThemeMode(option.mode);
                          Navigator.pop(sheetContext);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _ThemeOption {
  final ThemeMode mode;
  final String title;
  final String subtitle;
  final IconData icon;

  const _ThemeOption({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
