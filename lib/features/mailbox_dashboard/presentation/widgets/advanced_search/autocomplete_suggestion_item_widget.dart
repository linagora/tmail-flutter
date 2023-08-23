import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/autocomplete_suggestion_item_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/avatar_suggestion_item_widget.dart';

typedef OnSelectSuggestionItemCallback = Function(String emailAddress);

class AutocompleteSuggestionItemWidget extends StatelessWidget {

  final EmailAddress emailAddress;
  final OnSelectSuggestionItemCallback onSelectCallback;

  const AutocompleteSuggestionItemWidget({
    super.key,
    required this.emailAddress,
    required this.onSelectCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelectCallback(emailAddress.emailAddress),
        child: Container(
          padding: AutocompleteSuggestionItemStyle.padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AvatarSuggestionItemWidget(emailAddress: emailAddress),
              const SizedBox(width: AutocompleteSuggestionItemStyle.space),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (emailAddress.displayName.isNotEmpty)
                      Text(
                        emailAddress.displayName,
                        maxLines: 1,
                        softWrap: CommonTextStyle.defaultSoftWrap,
                        overflow: CommonTextStyle.defaultTextOverFlow,
                        style: AutocompleteSuggestionItemStyle.displayNameTextStyle
                      ),
                    if (emailAddress.emailAddress.isNotEmpty)
                      Text(
                        emailAddress.emailAddress,
                        maxLines: 1,
                        softWrap: CommonTextStyle.defaultSoftWrap,
                        overflow: CommonTextStyle.defaultTextOverFlow,
                        style: AutocompleteSuggestionItemStyle.emailAddressNameTextStyle
                      )
                  ]
                )
              ),
            ]
          ),
        ),
      ),
    );
  }
}
