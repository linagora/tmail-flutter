import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/email/presentation/model/twp_warning_code.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/twp_warning_banner_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnDismissTwpWarningAction = void Function(int index);

/// Colored banner for one backend-positioned `X-TWP-Message` warning, shown
/// between the header section and the body. Color follows [TwpWarning.level]
/// (info→blue, warn→yellow, error→red). The dismiss button (hidden when
/// [isDismissable] is false, e.g. offline) invokes [onDismissAction].
///
/// Layout/colors come from [TwpWarningBannerStyle].
class TwpWarningBanner extends StatelessWidget {
  final TwpWarning warning;
  final bool isDismissable;
  final OnDismissTwpWarningAction onDismissAction;
  final ImagePaths imagePaths;

  const TwpWarningBanner({
    super.key,
    required this.warning,
    required this.onDismissAction,
    required this.imagePaths,
    this.isDismissable = true,
  });

  @override
  Widget build(BuildContext context) {
    final style = TwpWarningBannerStyle.ofLevel(warning.level);
    final message = TwpWarningCodeResolver.resolveMessage(
      warning,
      AppLocalizations.of(context),
    );

    return Container(
      key: Key('${UiKeys.twpWarningBannerPrefix}${warning.index}'),
      margin: TwpWarningBannerStyle.margin,
      padding: TwpWarningBannerStyle.padding,
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(TwpWarningBannerStyle.borderRadius),
        ),
        border: Border.all(color: style.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            style.icon,
            color: style.iconColor,
            size: TwpWarningBannerStyle.iconSize,
          ),
          const SizedBox(width: TwpWarningBannerStyle.iconSpacing),
          Expanded(
            child: Text(
              message,
              style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: TwpWarningBannerStyle.messageFontSize,
                height: TwpWarningBannerStyle.messageLineHeight,
                color: style.textColor,
              ),
            ),
          ),
          if (isDismissable) ...[
            const SizedBox(width: TwpWarningBannerStyle.dismissSpacing),
            TMailButtonWidget.fromIcon(
              key: Key(
                '${UiKeys.twpWarningDismissButtonPrefix}${warning.index}',
              ),
              icon: imagePaths.icClose,
              iconSize: TwpWarningBannerStyle.dismissIconSize,
              iconColor: style.iconColor,
              backgroundColor: Colors.transparent,
              padding: TwpWarningBannerStyle.dismissPadding,
              tooltipMessage: AppLocalizations.of(context).dismiss,
              onTapActionCallback: () => onDismissAction(warning.index),
            ),
          ],
        ],
      ),
    );
  }
}
