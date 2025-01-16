
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/text/rich_text_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:super_tag_editor/widgets/rich_text_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/suggestion_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
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
          borderRadius: BorderRadius.all(Radius.circular(RecipientSuggestionItemWidgetStyle.radius)),
        ),
        height: ComposerStyle.suggestionItemHeight,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: RecipientSuggestionItemWidgetStyle.labelPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AvatarSuggestionItemWidget(emailAddress: emailAddress),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichTextWidget(
                          textOrigin: emailAddress.asString(),
                          wordSearched: suggestionValid ?? '',
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (emailAddress.displayName.isNotEmpty)
                          RichTextBuilder(
                            textOrigin: emailAddress.emailAddress,
                            wordToStyle: suggestionValid ?? '',
                            styleOrigin: RecipientSuggestionItemWidgetStyle.labelTextStyle,
                            styleWord: RecipientSuggestionItemWidgetStyle.labelHighlightTextStyle,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    imagePaths.icFilterSelected,
                    width: RecipientSuggestionItemWidgetStyle.selectedIconSize,
                    height: RecipientSuggestionItemWidgetStyle.selectedIconSize,
                    fit: BoxFit.fill,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        color: highlight ? AppColor.colorItemSelected : Colors.white,
        height: ComposerStyle.suggestionItemHeight,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onSelectedAction?.call(emailAddress),
            child: Padding(
              padding: RecipientSuggestionItemWidgetStyle.labelPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AvatarSuggestionItemWidget(emailAddress: emailAddress),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichTextWidget(
                          textOrigin: emailAddress.asString(),
                          wordSearched: suggestionValid ?? '',
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (emailAddress.displayName.isNotEmpty)
                          RichTextBuilder(
                            textOrigin: emailAddress.emailAddress,
                            wordToStyle: suggestionValid ?? '',
                            styleOrigin: RecipientSuggestionItemWidgetStyle.labelTextStyle,
                            styleWord: RecipientSuggestionItemWidgetStyle.labelHighlightTextStyle,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
