
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:super_tag_editor/widgets/rich_text_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/suggestion_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/recipient_suggestion_item_widget_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/avatar_suggestion_item_widget.dart';

typedef OnSelectedRecipientSuggestionAction = Function(EmailAddress emailAddress);

class RecipientSuggestionItemWidget extends StatelessWidget {

  final SuggestionEmailState suggestionState;
  final EmailAddress emailAddress;
  final ImagePaths imagePaths;
  final String? suggestionValid;
  final bool highlight;
  final OnSelectedRecipientSuggestionAction? onSelectedAction;

  const RecipientSuggestionItemWidget({
    super.key,
    required this.suggestionState,
    required this.emailAddress,
    required this.imagePaths,
    this.suggestionValid,
    this.highlight = false,
    this.onSelectedAction,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestionState == SuggestionEmailState.duplicated) {
      return Container(
        margin: RecipientSuggestionItemWidgetStyle.suggestionDuplicatedMargin,
        decoration: const BoxDecoration(
          color: AppColor.colorBgMenuItemDropDownSelected,
          borderRadius: BorderRadius.all(Radius.circular(RecipientSuggestionItemWidgetStyle.radius))
        ),
        child: Material(
          type: MaterialType.transparency,
          child: ListTile(
            contentPadding: RecipientSuggestionItemWidgetStyle.labelDuplicatedPadding,
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
                  overflow: TextOverflow.ellipsis,
                  styleTextOrigin: RecipientSuggestionItemWidgetStyle.labelTextStyle,
                  styleWordSearched: RecipientSuggestionItemWidgetStyle.labelHighlightTextStyle
                )
              : null,
            trailing: SvgPicture.asset(
              imagePaths.icFilterSelected,
              width: RecipientSuggestionItemWidgetStyle.selectedIconSize,
              height: RecipientSuggestionItemWidgetStyle.selectedIconSize,
              fit: BoxFit.fill
            ),
          ),
        )
      );
    } else {
      return Container(
        color: highlight ? AppColor.colorItemSelected : Colors.white,
        child: Material(
          type: MaterialType.transparency,
          child: ListTile(
            contentPadding: RecipientSuggestionItemWidgetStyle.labelPadding,
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
                  overflow: TextOverflow.ellipsis,
                  styleTextOrigin: RecipientSuggestionItemWidgetStyle.labelTextStyle,
                  styleWordSearched: RecipientSuggestionItemWidgetStyle.labelHighlightTextStyle
                )
              : null,
            onTap: () => onSelectedAction?.call(emailAddress),
          ),
        ),
      );
    }
  }
}
