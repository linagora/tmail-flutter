import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_autocomplete_input_field_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/draggable_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/draggable_recipient_tag_widget.dart';
import 'package:tmail_ui_user/features/base/model/filter_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/autocomplete_tag_item_web_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/avatar_tag_item_widget.dart';

class DefaultAutocompleteTagItemWidget extends StatelessWidget {

  final bool isCollapsed;
  final bool isLatestTagFocused;
  final bool isLatestEmail;
  final FilterField field;
  final EmailAddress currentEmailAddress;
  final String iconClose;
  final List<EmailAddress> currentListEmailAddress;
  final List<EmailAddress> collapsedListEmailAddress;
  final OnDeleteTagAction? onDeleteTagAction;
  final OnShowFullListEmailAddressAction? onShowFullAction;

  const DefaultAutocompleteTagItemWidget({
    Key? key,
    required this.field,
    required this.currentEmailAddress,
    required this.currentListEmailAddress,
    required this.collapsedListEmailAddress,
    required this.iconClose,
    this.isCollapsed = false,
    this.isLatestTagFocused = false,
    this.isLatestEmail = false,
    this.onDeleteTagAction,
    this.onShowFullAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            top: AutoCompleteTagItemWebStyle.paddingTop,
            end: isCollapsed ? AutoCompleteTagItemWebStyle.paddingEnd : 0,
          ),
          child: Draggable<DraggableEmailAddress>(
            data: DraggableEmailAddress(
              emailAddress: currentEmailAddress,
              filterField: field,
            ),
            feedback: DraggableRecipientTagWidget(
              emailAddress: currentEmailAddress,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            ),
            childWhenDragging: DraggableRecipientTagWidget(
              emailAddress: currentEmailAddress,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                      horizontal: AutoCompleteTagItemWebStyle.labelPaddingHorizontal,
                      vertical: DirectionUtils.isDirectionRTLByHasAnyRtl(currentEmailAddress.asString()) ? 0 : 2
                    ),
                    label: Text(
                      currentEmailAddress.asString(),
                      maxLines: 1,
                      overflow: CommonTextStyle.defaultTextOverFlow,
                      softWrap: CommonTextStyle.defaultSoftWrap,
                    ),
                    deleteIcon: SvgPicture.asset(
                      iconClose,
                      fit: BoxFit.fill,
                    ),
                    padding: EdgeInsets.zero,
                    labelStyle: AutoCompleteTagItemWebStyle.labelTextStyle,
                    backgroundColor: _getTagBackgroundColor(),
                    shape: RoundedRectangleBorder(
                      borderRadius: AutoCompleteTagItemWebStyle.shapeBorderRadius,
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
        ),
        if (isCollapsed)
          TMailButtonWidget.fromText(
            margin: AutoCompleteTagItemWebStyle.marginCollapsed,
            text: '+${currentListEmailAddress.length - collapsedListEmailAddress.length}',
            onTapActionCallback: () => onShowFullAction?.call(field),
            borderRadius: 10,
            textStyle: AutoCompleteTagItemWebStyle.collapsedTextStyle,
            padding: AutoCompleteTagItemWebStyle.collapsedPadding,
            backgroundColor: AutoCompleteTagItemWebStyle.collapsedBackgroundColor,
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
      return const BorderSide(width: 1, color: AppColor.primaryColor);
    } else {
      return const BorderSide(width: 0, color: AppColor.colorEmailAddressTag);
    }
  }
}
