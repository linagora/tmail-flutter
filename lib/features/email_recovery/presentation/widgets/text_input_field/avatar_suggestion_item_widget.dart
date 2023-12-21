import 'package:core/core.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/styles/text_input_field/avatar_suggestion_item_widget_styles.dart';

class AvatarSuggestionItemWidget extends StatelessWidget {
  final EmailAddress emailAddress;

  const AvatarSuggestionItemWidget({super.key, required this.emailAddress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AvatarSuggestionItemWidgetStyles.width,
      height: AvatarSuggestionItemWidgetStyles.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.avatarColor,
        border: Border.all(
          color: AppColor.colorShadowBgContentEmail,
          width: AvatarSuggestionItemWidgetStyles.borderWidth
        )
      ),
      child: Text(
        emailAddress.asString().isNotEmpty
          ? emailAddress.asString().firstLetterToUpperCase
          : '',
        style: AvatarSuggestionItemWidgetStyles.textStyle,
      ),
    );
  }
}