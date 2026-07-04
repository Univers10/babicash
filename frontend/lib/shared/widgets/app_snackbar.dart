import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

abstract final class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    Color backgroundColor = AppColors.textPrimary,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 18),
                const HGap(AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppSpacing.lg),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      show(context, message,
          backgroundColor: AppColors.success, icon: Symbols.check_circle);

  static void error(BuildContext context, String message) =>
      show(context, message,
          backgroundColor: AppColors.error, icon: Symbols.error);

  static void warning(BuildContext context, String message) =>
      show(context, message,
          backgroundColor: AppColors.warning, icon: Symbols.warning);

  static void info(BuildContext context, String message) =>
      show(context, message, icon: Symbols.info);
}
