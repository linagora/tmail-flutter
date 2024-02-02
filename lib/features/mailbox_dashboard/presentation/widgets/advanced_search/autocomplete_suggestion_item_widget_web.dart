import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:super_tag_editor/widgets/rich_text_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/suggesstion_email_address.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/autocomplete_suggestion_item_web_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/avatar_suggestion_item_widget.dart';

typedef OnSelectedRecipientSuggestionAction = Function(EmailAddress emailAddress);

class AutoCompleteSuggestionItemWidgetWeb extends StatelessWidget {

  final SuggestionEmailState suggestionState;
  final EmailAddress emailAddress;
  final String? suggestionValid;
  final bool highlight;
  final OnSelectedRecipientSuggestionAction? onSelectedAction;

  final _imagePaths = Get.find<ImagePaths>();

  AutoCompleteSuggestionItemWidgetWeb({
    Key? key,
    required this.suggestionState,
    required this.emailAddress,
    this.highlight = false,
    this.suggestionValid,
    this.onSelectedAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (suggestionState == SuggestionEmailState.duplicated) {
      return Container(
        margin: AutoCompleteSuggestionItemWebStyle.margin,
        decoration: AutoCompleteSuggestionItemWebStyle.decoration,
        child: Material(
          type: MaterialType.transparency,
          child: ListTile(
            contentPadding: AutoCompleteSuggestionItemWebStyle.contentPaddingDuplicated,
            leading: AvatarSuggestionItemWidget(emailAddress: emailAddress),
            title: RichTextWidget(
              textOrigin: emailAddress.asString(),
              wordSearched: suggestionValid ?? '',
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: emailAddress.displayName.isNotEmpty
              ? RichTextWidget(
                  textOrigin: emailAddress.emailAddress,
                  wordSearched: suggestionValid ?? '',
                  styleTextOrigin: AutoCompleteSuggestionItemWebStyle.subTitleTextOriginStyle,
                  styleWordSearched: AutoCompleteSuggestionItemWebStyle.subTitleWordSearchStyle,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
            trailing: SvgPicture.asset(
              _imagePaths.icFilterSelected,
              width: AutoCompleteSuggestionItemWebStyle.iconSize,
              height: AutoCompleteSuggestionItemWebStyle.iconSize,
              fit: BoxFit.fill,
            ),
          ),
        ),
      );
    } else {
      return Container(
        color: highlight ? AppColor.colorItemSelected : Colors.white,
        child: Material(
          type: MaterialType.transparency,
          child: ListTile(
            contentPadding: AutoCompleteSuggestionItemWebStyle.contentPaddingValid,
            leading: AvatarSuggestionItemWidget(emailAddress: emailAddress),
            title: RichTextWidget(
              textOrigin: emailAddress.asString(),
              wordSearched: suggestionValid ?? '',
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: emailAddress.displayName.isNotEmpty
              ? RichTextWidget(
                  textOrigin: emailAddress.emailAddress,
                  wordSearched: suggestionValid ?? '',
                  styleTextOrigin: AutoCompleteSuggestionItemWebStyle.subTitleTextOriginStyle,
                  styleWordSearched: AutoCompleteSuggestionItemWebStyle.subTitleWordSearchStyle,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
            onTap: () => onSelectedAction?.call(emailAddress),
          ),
        ),
      );
    }
  }
}
