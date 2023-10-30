
import 'package:core/core.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/advanced_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/autocomplete_tag_item_web_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/avatar_tag_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/text_field_autocomplete_email_address_web.dart';

class AutoCompleteTagItemWidgetWeb extends StatelessWidget {

  final bool isCollapsed;
  final bool isLatestTagFocused;
  final bool isLatestEmail;
  final AdvancedSearchFilterField field;
  final EmailAddress currentEmailAddress;
  final List<EmailAddress> currentListEmailAddress;
  final List<EmailAddress> collapsedListEmailAddress;
  final OnDeleteTagAction? onDeleteTagAction;
  final OnShowFullListEmailAddressAction? onShowFullAction;

  final _imagePaths = Get.find<ImagePaths>();

  AutoCompleteTagItemWidgetWeb({
    Key? key,
    required this.field,
    required this.currentEmailAddress,
    required this.currentListEmailAddress,
    required this.collapsedListEmailAddress,
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
          child: InkWell(
            onTap: () => isCollapsed
              ? null
              : onShowFullAction?.call(field),
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
                  _imagePaths.icClose,
                  fit: BoxFit.fill,
                ),
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
    } else if (GetUtils.isEmail(currentEmailAddress.emailAddress)) {
      return AppColor.colorEmailAddressTag;
    } else {
      return Colors.white;
    }
  }

  BorderSide _getTagBorderSide() {
    if (isLatestTagFocused && isLatestEmail) {
      return const BorderSide(width: 1, color: AppColor.primaryColor);
    } else if (GetUtils.isEmail(currentEmailAddress.emailAddress)) {
      return BorderSide.none;
    } else {
      return const BorderSide(
        width: 1,
        color: AppColor.colorBorderEmailAddressInvalid
      );
    }
  }
}
