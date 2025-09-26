import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
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

  final ImagePaths imagePaths;
  final bool isCollapsed;
  final bool isTagFocused;
  final FilterField field;
  final EmailAddress currentEmailAddress;
  final String iconClose;
  final List<EmailAddress> currentListEmailAddress;
  final List<EmailAddress> collapsedListEmailAddress;
  final OnDeleteTagAction? onDeleteTagAction;
  final OnShowFullListEmailAddressAction? onShowFullAction;

  const DefaultAutocompleteTagItemWidget({
    Key? key,
    required this.imagePaths,
    required this.field,
    required this.currentEmailAddress,
    required this.currentListEmailAddress,
    required this.collapsedListEmailAddress,
    required this.iconClose,
    this.isCollapsed = false,
    this.isTagFocused = false,
    this.onDeleteTagAction,
    this.onShowFullAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget = Chip(
      labelPadding: EdgeInsetsDirectional.symmetric(
        horizontal: AutoCompleteTagItemWebStyle.labelPaddingHorizontal,
        vertical: DirectionUtils.isDirectionRTLByHasAnyRtl(currentEmailAddress.asString()) ? 0 : 2,
      ),
      label: Text(
        currentEmailAddress.asString(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AutoCompleteTagItemWebStyle.labelTextStyle,
      ),
      deleteIcon: SvgPicture.asset(iconClose, fit: BoxFit.fill),
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
    );

    if (PlatformInfo.isWeb) {
      bodyWidget = Draggable<DraggableEmailAddress>(
        data: DraggableEmailAddress(
          emailAddress: currentEmailAddress,
          filterField: field,
        ),
        feedback: DraggableRecipientTagWidget(
          emailAddress: currentEmailAddress,
          imagePaths: imagePaths,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        ),
        childWhenDragging: DraggableRecipientTagWidget(
          emailAddress: currentEmailAddress,
          imagePaths: imagePaths,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        ),
        child: TextFieldTapRegion(
          child: InkWell(
            onTap: () => isCollapsed ? onShowFullAction?.call(field) : null,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: bodyWidget,
            ),
          ),
        ),
      );
    } else {
      bodyWidget = TextFieldTapRegion(
        child: InkWell(
          onTap: () => isCollapsed ? onShowFullAction?.call(field) : null,
          child: bodyWidget,
        ),
      );
    }

    final listChildrenWidget = [
      if (isCollapsed)
        Flexible(child: bodyWidget)
      else
        bodyWidget,
      if (isCollapsed)
        TMailButtonWidget.fromText(
          margin: const EdgeInsetsDirectional.only(start: 8),
          text: '+${currentListEmailAddress.length - collapsedListEmailAddress.length}',
          onTapActionCallback: () => onShowFullAction?.call(field),
          borderRadius: 10,
          alignment: Alignment.center,
          textStyle: AutoCompleteTagItemWebStyle.collapsedTextStyle,
          padding: PlatformInfo.isWeb
            ? const EdgeInsetsDirectional.symmetric(vertical: 4, horizontal: 8)
            : const EdgeInsetsDirectional.symmetric(vertical: 6, horizontal: 10),
          backgroundColor: AutoCompleteTagItemWebStyle.collapsedBackgroundColor,
        )
    ];

    Widget tagWidget;
    if (listChildrenWidget.length == 1) {
      tagWidget = listChildrenWidget.first;
    } else {
      tagWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: listChildrenWidget,
      );
    }

    if (PlatformInfo.isWeb) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(top: 3),
        child: tagWidget,
      );
    } else {
      return tagWidget;
    }
  }

  Color _getTagBackgroundColor() {
    if (isTagFocused) {
      return AppColor.colorItemRecipientSelected;
    } else {
      return AppColor.colorEmailAddressTag;
    }
  }

  BorderSide _getTagBorderSide() {
    if (isTagFocused) {
      return const BorderSide(width: 1, color: AppColor.primaryColor);
    } else {
      return const BorderSide(width: 0, color: AppColor.colorEmailAddressTag);
    }
  }
}
