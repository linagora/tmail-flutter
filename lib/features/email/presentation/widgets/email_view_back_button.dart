
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_back_button_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailViewBackButton extends StatelessWidget {

  final ImagePaths imagePaths;
  final bool isSearchActivated;
  final VoidCallback onBackAction;
  final double maxWidth;
  final PresentationMailbox? mailboxContain;

  const EmailViewBackButton({
    super.key,
    required this.imagePaths,
    required this.onBackAction,
    required this.isSearchActivated,
    required this.maxWidth,
    this.mailboxContain,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSearchActivated) {
      return TMailButtonWidget(
        text: mailboxContain?.getDisplayName(context) ?? '',
        icon: DirectionUtils.isDirectionRTLByLanguage(context)
          ? imagePaths.icArrowRight
          : imagePaths.icBack,
        iconColor: EmailViewBackButtonStyles.iconColor,
        textStyle: EmailViewBackButtonStyles.labelTextStyle,
        backgroundColor: Colors.transparent,
        mainAxisSize: MainAxisSize.min,
        padding: DirectionUtils.isDirectionRTLByLanguage(context)
          ? EmailViewBackButtonStyles.rtlPadding
          : null,
        maxWidth: maxWidth - EmailViewBackButtonStyles.offsetWidth,
        flexibleText: true,
        maxLines: 1,
        tooltipMessage: AppLocalizations.of(context).back,
        onTapActionCallback: onBackAction,
      );
    } else {
      return TMailButtonWidget.fromIcon(
        icon: DirectionUtils.isDirectionRTLByLanguage(context)
          ? imagePaths.icArrowRight
          : imagePaths.icBack,
        iconColor: EmailViewBackButtonStyles.iconColor,
        padding: DirectionUtils.isDirectionRTLByLanguage(context)
          ? EmailViewBackButtonStyles.rtlPadding
          : null,
        backgroundColor: Colors.transparent,
        tooltipMessage: AppLocalizations.of(context).backToSearchResults,
        onTapActionCallback: onBackAction,
      );
    }
  }
}