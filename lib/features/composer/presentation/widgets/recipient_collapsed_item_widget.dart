import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/views/avatar/gradient_circle_avatar_icon.dart';
import 'package:core/presentation/views/text/middle_ellipsis_text.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/recipient_tag_item_widget_style.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

class RecipientCollapsedItemWidget extends StatelessWidget {
  final EmailAddress emailAddress;
  final bool isRejectedByServer;

  const RecipientCollapsedItemWidget({
    super.key,
    required this.emailAddress,
    this.isRejectedByServer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 267),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(RecipientTagItemWidgetStyle.radius),
        ),
        border: _getTagBorder(),
        color: _getTagBackgroundColor(),
      ),
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GradientCircleAvatarIcon(
            colors: emailAddress.avatarColors,
            label: emailAddress.asString().firstCharacterToUpperCase,
            textStyle: RecipientTagItemWidgetStyle.avatarTextStyle,
            iconSize: RecipientTagItemWidgetStyle.avatarIconSize,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: MiddleEllipsisText(
              emailAddress.asString(),
              style: RecipientTagItemWidgetStyle.labelTextStyle,
            )
          ),
        ],
      ),
    );
  }

  /// An address is invalid when it is malformed, or when the server rejected it
  /// as an `invalidRecipients` of the last `EmailSubmission/set`.
  bool get _isEmailAddressValid =>
      !isRejectedByServer && EmailUtils.isValidEmail(emailAddress.emailAddress);

  Color _getTagBackgroundColor() {
    if (_isEmailAddressValid) {
      return AppColor.grayBackgroundColor;
    } else {
      return Colors.white;
    }
  }

  Border _getTagBorder() {
    if (_isEmailAddressValid) {
      return Border.all(
        width: 1,
        color: AppColor.grayBackgroundColor,
      );
    } else {
      return Border.all(
        width: 1,
        color: AppColor.colorBorderEmailAddressInvalid,
      );
    }
  }
}
