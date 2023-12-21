import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_field.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/styles/text_input_field/suggestion_tag_item_widget_styles.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/text_input_field/avatar_tag_item_widget.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/text_input_field/text_input_field_suggestion_widget.dart';

class SuggestionTagItemWidget extends StatelessWidget {
  final bool isCollapsed;
  final bool isLatestTagFocused;
  final bool isLatestEmail;
  final EmailRecoveryField field;
  final EmailAddress currentEmailAddress;
  final List<EmailAddress> currentListEmailAddress;
  final List<EmailAddress> collapsedListEmailAddress;
  final OnDeleteTagAction? onDeleteTagAction;
  final OnShowFullListEmailAddressAction? onShowFullAction;

  final _imagePaths = Get.find<ImagePaths>();

  SuggestionTagItemWidget({
    super.key,
    required this.field,
    required this.currentEmailAddress,
    required this.currentListEmailAddress,
    required this.collapsedListEmailAddress,
    this.isCollapsed = false,
    this.isLatestTagFocused = false,
    this.isLatestEmail = false,
    this.onDeleteTagAction,
    this.onShowFullAction,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            top: SuggestionTagItemWidgetStyles.paddingTop,
            end: isCollapsed
              ? SuggestionTagItemWidgetStyles.paddingEndCollapsed
              : SuggestionTagItemWidgetStyles.paddingEndExpanded,
          ),
          child: TextFieldTapRegion(
            child: InkWell(
              onTap: () => isCollapsed
                ? onShowFullAction?.call(field)
                : null,
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: Chip(
                  labelPadding: EdgeInsetsDirectional.symmetric(
                    horizontal: SuggestionTagItemWidgetStyles.labelPaddingHorizontal,
                    vertical: DirectionUtils.isDirectionRTLByHasAnyRtl(currentEmailAddress.asString())
                      ? 0
                      : SuggestionTagItemWidgetStyles.labelPaddingVertical,
                  ),
                  label: Text(
                    currentEmailAddress.asString(),
                    maxLines: 1,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                  ),
                  deleteIcon: SvgPicture.asset(
                    _imagePaths.icClose,
                    fit: BoxFit.fill,
                  ),
                  labelStyle: SuggestionTagItemWidgetStyles.labelStyle,
                  backgroundColor: _getTagBackgroundColor(),
                  shape: RoundedRectangleBorder(
                    borderRadius: SuggestionTagItemWidgetStyles.borderRadius,
                    side: _getTagBorderSide(),
                  ),
                  avatar: currentEmailAddress.emailAddress.isNotEmpty
                    ? AvatarTagItemWidget(tagName: currentEmailAddress.emailAddress)
                    : null,
                  onDeleted: () => onDeleteTagAction?.call(currentEmailAddress),
                ),
              ),
            ),
          ),
        ),
        if (isCollapsed)
          TMailButtonWidget.fromText(
            margin: SuggestionTagItemWidgetStyles.collapsedTextMargin,
            text: '+${currentListEmailAddress.length - collapsedListEmailAddress.length}',
            onTapActionCallback: () => onShowFullAction?.call(field),
            borderRadius: SuggestionTagItemWidgetStyles.collapsedTextBorderRadius,
            textStyle: SuggestionTagItemWidgetStyles.labelStyle,
            padding: SuggestionTagItemWidgetStyles.collapsedTextPadding,
            backgroundColor: AppColor.colorEmailAddressTag,
          )
      ],
    );
  }

  Color _getTagBackgroundColor() {
    if (isLatestTagFocused && isLatestEmail) {
      return AppColor.colorItemRecipientSelected;
    } else {
      return AppColor.colorEmailAddressTag;
    }
  }

  BorderSide _getTagBorderSide() {
    if (isLatestTagFocused && isLatestEmail) {
      return SuggestionTagItemWidgetStyles.latestTagBorderSide;
    } else {
      return BorderSide.none;
    }
  }
}