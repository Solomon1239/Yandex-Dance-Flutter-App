import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';

enum AppSnackBarType { error, success, info }

class AppSnackBar {
  const AppSnackBar._();

  static void showError(BuildContext context, String message) =>
      _show(context, message, AppSnackBarType.error);

  static void showSuccess(BuildContext context, String message) =>
      _show(context, message, AppSnackBarType.success);

  static void showInfo(BuildContext context, String message) =>
      _show(context, message, AppSnackBarType.info);

  static void _show(
    BuildContext context,
    String message,
    AppSnackBarType type,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: _AppSnackBarBody(message: message, type: type),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

class _AppSnackBarBody extends StatelessWidget {
  const _AppSnackBarBody({required this.message, required this.type});

  final String message;
  final AppSnackBarType type;

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(type);
    final icon = _icon(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gray400,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [accent, accent.withValues(alpha: 0.55)],
              ),
            ),
            child: Icon(icon, size: 18, color: AppColors.gray0),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextTheme.body2Regular14pt.copyWith(
                color: AppColors.gray0,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _accentColor(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.error:
        return AppColors.pink500;
      case AppSnackBarType.success:
        return AppColors.purple500;
      case AppSnackBarType.info:
        return AppColors.gray300;
    }
  }

  IconData _icon(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.error:
        return Icons.error_outline;
      case AppSnackBarType.success:
        return Icons.check_rounded;
      case AppSnackBarType.info:
        return Icons.info_outline;
    }
  }
}
