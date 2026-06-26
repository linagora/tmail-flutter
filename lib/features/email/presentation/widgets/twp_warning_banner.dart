import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/presentation/model/twp_warning_code.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnDismissTwpWarningAction = void Function(int index);

/// Colored banner displayed between the header section and the body of the read
/// view for a backend positioned `X-TWP-Message` warning.
///
/// The color follows [TwpWarning.level] (info -> blue, warn -> yellow,
/// error -> red). A dismiss button persists the decision through a keyword; it
/// is hidden when [isDismissable] is false (e.g. offline).
class TwpWarningBanner extends StatelessWidget {
  final TwpWarning warning;
  final bool isDismissable;
  final OnDismissTwpWarningAction onDismissAction;

  const TwpWarningBanner({
    super.key,
    required this.warning,
    required this.onDismissAction,
    this.isDismissable = true,
  });

  @override
  Widget build(BuildContext context) {
    final style = _TwpWarningBannerStyle.fromLevel(warning.level);
    final message = TwpWarningCodeResolver.resolveMessage(
      warning,
      AppLocalizations.of(context),
    );

    return Container(
      margin: const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12, top: 2),
            child: Icon(style.icon, color: style.iconColor, size: 20),
          ),
          Expanded(
            child: Text(
              message,
              style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 15,
                color: style.textColor,
              ),
            ),
          ),
          if (isDismissable)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: InkWell(
                onTap: () => onDismissAction(warning.index),
                customBorder: const CircleBorder(),
                child: Tooltip(
                  message: AppLocalizations.of(context).dismiss,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.close, color: style.iconColor, size: 20),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TwpWarningBannerStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final IconData icon;

  const _TwpWarningBannerStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
    required this.icon,
  });

  factory _TwpWarningBannerStyle.fromLevel(TwpWarningLevel level) {
    switch (level) {
      case TwpWarningLevel.error:
        return const _TwpWarningBannerStyle(
          backgroundColor: Color(0xFFFDECEA),
          borderColor: Color(0xFFF5C6C0),
          textColor: Color(0xFF8B1A10),
          iconColor: Color(0xFFD32F2F),
          icon: Icons.dangerous_outlined,
        );
      case TwpWarningLevel.warn:
        return const _TwpWarningBannerStyle(
          backgroundColor: Color(0xFFFFF8E1),
          borderColor: Color(0xFFF3E0A6),
          textColor: Color(0xFF7A5A00),
          iconColor: Color(0xFFF9A825),
          icon: Icons.warning_amber_rounded,
        );
      case TwpWarningLevel.info:
        return const _TwpWarningBannerStyle(
          backgroundColor: Color(0xFFE8F1FE),
          borderColor: Color(0xFFBBD6FB),
          textColor: Color(0xFF0B4A8F),
          iconColor: Color(0xFF1A73E8),
          icon: Icons.info_outline,
        );
    }
  }
}
