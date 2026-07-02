import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:model/email/twp_warning.dart';
import 'package:tmail_ui_user/features/email/presentation/providers/twp_warning_notifier.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/twp_warning_messages.dart';

class TwpWarningBanner extends ConsumerWidget {
  const TwpWarningBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(twpWarningProvider);
    if (state.warnings.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final warning in state.warnings)
          _TwpWarningBannerRow(warning: warning, l10n: l10n),
      ],
    );
  }
}

class _TwpWarningBannerRow extends StatelessWidget {
  final TwpWarning warning;
  final AppLocalizations l10n;

  const _TwpWarningBannerRow({required this.warning, required this.l10n});

  static const _infoColor = Color(0xFF007AFF);
  static const _warnColor = Color(0xFFF29900);
  static const _errorColor = AppColor.colorErrorState;

  Color get _levelColor {
    switch (warning.level) {
      case TwpWarningLevel.warn:
        return _warnColor;
      case TwpWarningLevel.error:
        return _errorColor;
      case TwpWarningLevel.info:
        return _infoColor;
    }
  }

  IconData get _levelIcon {
    switch (warning.level) {
      case TwpWarningLevel.warn:
        return Icons.warning_amber_rounded;
      case TwpWarningLevel.error:
        return Icons.error_outline_rounded;
      case TwpWarningLevel.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(top: 8, start: 20, end: 20),
      padding: const EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: _levelColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _levelColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_levelIcon, color: _levelColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              TwpWarningMessages.resolve(l10n, warning),
              style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: AppColor.labelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
