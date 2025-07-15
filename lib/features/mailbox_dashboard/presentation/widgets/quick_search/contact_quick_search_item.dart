
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/avatar_suggestion_item_widget.dart';

class ContactQuickSearchItem extends StatelessWidget {
  final EmailAddress emailAddress;

  const ContactQuickSearchItem({
    super.key,
    required this.emailAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          AvatarSuggestionItemWidget(emailAddress: emailAddress),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emailAddress.asString(),
                  maxLines: 1,
                  softWrap: CommonTextStyle.defaultSoftWrap,
                  overflow: CommonTextStyle.defaultTextOverFlow,
                  style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.normal
                  )
                ),
                if (emailAddress.displayName.isNotEmpty)
                  Text(
                    emailAddress.emailAddress,
                    maxLines: 1,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                      color: AppColor.colorHintSearchBar,
                      fontSize: 13,
                      fontWeight: FontWeight.normal
                    )
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}