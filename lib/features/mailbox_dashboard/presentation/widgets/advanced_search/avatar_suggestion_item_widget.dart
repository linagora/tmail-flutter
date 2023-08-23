import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/avatar_suggestion_item_style.dart';

class AvatarSuggestionItemWidget extends StatelessWidget {

  final EmailAddress emailAddress;

  const AvatarSuggestionItemWidget({super.key, required this.emailAddress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AvatarSuggestionItemStyle.iconSize,
      height: AvatarSuggestionItemStyle.iconSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AvatarSuggestionItemStyle.iconColor,
        border: Border.all(
          color: AvatarSuggestionItemStyle.iconBorderColor,
          width: AvatarSuggestionItemStyle.iconBorderSize
        )
      ),
      child: Text(
        emailAddress.asString().isNotEmpty
          ? emailAddress.asString()[0].toUpperCase()
          : '',
        style: AvatarSuggestionItemStyle.labelTextStyle
      )
    );
  }
}
