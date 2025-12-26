// lib/features/home/widgets/theme_language_switcher.dart
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lockin/core/theme/app_theme.dart';
import 'package:lockin/core/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeLanguageSwitcher extends StatelessWidget {
  const ThemeLanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Row(
      children: [
        // زر الثيم مع الأنيميشن الدائري
        ThemeSwitcher(
          builder: (context) {
            return IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: textPrimary,
                size: 28.sp,
              ),
              onPressed: () async {
                final newTheme = isDark
                    ? AppTheme.lightTheme
                    : AppTheme.darkTheme;

                ThemeSwitcher.of(context).changeTheme(theme: newTheme);

                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('is_dark_mode', !isDark);
              },
            );
          },
        ),

        // زر اللغة
        IconButton(
          tooltip: 'change_language'.tr(),
          onPressed: () {
            context.setLocale(
              context.locale.languageCode == 'en'
                  ? const Locale('ar')
                  : const Locale('en'),
            );
          },
          icon: Icon(Icons.language, color: textPrimary, size: 28.sp),
        ),
        SizedBox(width: 10.w),
      ],
    );
  }
}
