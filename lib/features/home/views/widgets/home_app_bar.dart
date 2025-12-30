// lib/features/home/widgets/home_app_bar.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lockin/core/config/app_config.dart';
import 'package:lockin/core/routes/routes.dart';
import 'package:lockin/core/theme/colors.dart';
import 'theme_language_switcher.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textPrimary = Theme.of(context).brightness == Brightness.dark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = Theme.of(context).brightness == Brightness.dark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final now = DateTime.now();
    final dayName = DateFormat('EEEE', context.locale.languageCode).format(now);
    final dateFormatted = DateFormat(
      'd MMMM yyyy',
      context.locale.languageCode,
    ).format(now);

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Image(
            image: AssetImage(AppConfig.appLogo),
            width: 50.w,
            height: 50.h,
          ),
          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppConfig.appName,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$dayName, $dateFormatted',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        const ThemeLanguageSwitcher(), // زر الإشعارات
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              // Badge لو في إشعارات غير مقروءة (اختياري)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '3', // يمكنك جلب العدد من SharedPrefs
                    style: TextStyle(fontSize: 10.sp, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.pushNamed(context, Routes.notifications);
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
