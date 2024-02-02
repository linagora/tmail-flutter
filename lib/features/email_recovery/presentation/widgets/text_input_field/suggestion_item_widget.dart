import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:super_tag_editor/widgets/rich_text_widget.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/styles/text_input_field/suggestion_item_widget_styles.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/text_input_field/avatar_suggestion_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/suggesstion_email_address.dart';

typedef OnSelectedRecipientSuggestionAction = void Function(EmailAddress emailAddress);

class SuggestionItemWidget extends StatelessWidget {
  final SuggestionEmailState suggestionState;
  final EmailAddress emailAddress;
  final String? suggestionValid;
  final bool highlight;
  final OnSelectedRecipientSuggestionAction? onSelectedAction;

  final _imagePaths = Get.find<ImagePaths>();

  SuggestionItemWidget({
    super.key,
    required this.suggestionState,
    required this.emailAddress,
    this.highlight = false,
    this.suggestionValid,
    this.onSelectedAction,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestionState == SuggestionEmailState.duplicated) {
      return Container(
        margin: SuggestionItemWidgetStyles.margin,
        decoration: SuggestionItemWidgetStyles.decoration,
        child: Material(
          type: MaterialType.transparency,
          child: ListTile(
            contentPadding: SuggestionItemWidgetStyles.contentPaddingDuplicated,
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
                  styleTextOrigin: SuggestionItemWidgetStyles.subTitleTextOriginStyle,
                  styleWordSearched: SuggestionItemWidgetStyles.subTitleWordSearchedStyle,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
            trailing: SvgPicture.asset(
              _imagePaths.icFilterSelected,
              width: SuggestionItemWidgetStyles.iconSelectedSize,
              height: SuggestionItemWidgetStyles.iconSelectedSize,
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
            contentPadding: SuggestionItemWidgetStyles.contentPaddingValid,
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
                  styleTextOrigin: SuggestionItemWidgetStyles.subTitleTextOriginStyle,
                  styleWordSearched: SuggestionItemWidgetStyles.subTitleWordSearchedStyle,
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