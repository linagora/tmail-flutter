import 'package:core/presentation/action/popup_menu_action.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/avatar/gradient_circle_avatar_icon.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/popup_menu/popup_menu_button_builder.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/draggable_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/recipient_action.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/recipient_tag_item_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/draggable_recipient_tag_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class RecipientTagItemWidget extends StatelessWidget {

  final bool isCollapsed;
  final bool isLatestTagFocused;
  final bool isLatestEmail;
  final double? maxWidth;
  final PrefixEmailAddress prefix;
  final EmailAddress currentEmailAddress;
  final List<EmailAddress> currentListEmailAddress;
  final List<EmailAddress> collapsedListEmailAddress;
  final OnShowFullListEmailAddressAction? onShowFullAction;
  final OnDeleteTagAction? onDeleteTagAction;
  final OnSelectRecipientAction? onSelectRecipientAction;

  final _imagePaths = Get.find<ImagePaths>();

  RecipientTagItemWidget({
    super.key,
    required this.prefix,
    required this.currentEmailAddress,
    required this.currentListEmailAddress,
    required this.collapsedListEmailAddress,
    this.isCollapsed = false,
    this.isLatestTagFocused = false,
    this.isLatestEmail = false,
    this.onShowFullAction,
    this.onDeleteTagAction,
    this.maxWidth,
    this.onSelectRecipientAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (PlatformInfo.isWeb)
            Flexible(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  top: !PlatformInfo.isCanvasKit ? 0 : 8
                ),
                child: Draggable<DraggableEmailAddress>(
                  data: DraggableEmailAddress(emailAddress: currentEmailAddress, prefix: prefix),
                  feedback: DraggableRecipientTagWidget(emailAddress: currentEmailAddress),
                  childWhenDragging: DraggableRecipientTagWidget(emailAddress: currentEmailAddress),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: PopupMenuButtonBuilder<RecipientAction>(
                      listAction: _buildListRecipientAction(context),
                      childBuilder: (isSelected) => Chip(
                        labelPadding: EdgeInsetsDirectional.symmetric(
                          horizontal: 4,
                          vertical: DirectionUtils.isDirectionRTLByHasAnyRtl(currentEmailAddress.asString()) ? 0 : 2
                        ),
                        padding: EdgeInsets.zero,
                        label: Text(
                          currentEmailAddress.asString(),
                          maxLines: 1,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                        ),
                        deleteIcon: SvgPicture.asset(_imagePaths.icClose, fit: BoxFit.fill),
                        labelStyle: RecipientTagItemWidgetStyle.labelTextStyle,
                        backgroundColor: _getTagBackgroundColor(isSelected),
                        side: _getTagBorderSide(isSelected),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(RecipientTagItemWidgetStyle.radius)),
                        ),
                        avatar: currentEmailAddress.displayName.isNotEmpty
                          ? GradientCircleAvatarIcon(
                              colors: currentEmailAddress.avatarColors,
                              label: currentEmailAddress.displayName.firstLetterToUpperCase,
                              labelFontSize: RecipientTagItemWidgetStyle.avatarLabelFontSize,
                              iconSize: RecipientTagItemWidgetStyle.avatarIconSize,
                            )
                          : null,
                        onDeleted: () => onDeleteTagAction?.call(currentEmailAddress),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Flexible(
              child: PopupMenuButtonBuilder(
                listAction: _buildListRecipientAction(context),
                childBuilder: (isSelected) => Chip(
                  labelPadding: EdgeInsetsDirectional.symmetric(
                    horizontal: 4,
                    vertical: DirectionUtils.isDirectionRTLByHasAnyRtl(currentEmailAddress.asString()) ? 0 : 2
                  ),
                  label: Text(
                    currentEmailAddress.asString(),
                    maxLines: 1,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                  ),
                  padding: EdgeInsets.zero,
                  deleteIcon: SvgPicture.asset(_imagePaths.icClose, fit: BoxFit.fill),
                  labelStyle: RecipientTagItemWidgetStyle.labelTextStyle,
                  backgroundColor: _getTagBackgroundColor(isSelected),
                  side: _getTagBorderSide(isSelected),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(RecipientTagItemWidgetStyle.radius)),
                  ),
                  avatar: currentEmailAddress.displayName.isNotEmpty
                    ? GradientCircleAvatarIcon(
                        colors: currentEmailAddress.avatarColors,
                        label: currentEmailAddress.displayName.firstLetterToUpperCase,
                        labelFontSize: RecipientTagItemWidgetStyle.avatarLabelFontSize,
                        iconSize: RecipientTagItemWidgetStyle.avatarIconSize,
                      )
                    : null,
                  onDeleted: () => onDeleteTagAction?.call(currentEmailAddress),
                ),
              ),
            ),
          if (isCollapsed)
            TMailButtonWidget.fromText(
              margin: _counterMargin,
              text: '+$countRecipients',
              onTapActionCallback: () => onShowFullAction?.call(prefix),
              borderRadius: RecipientTagItemWidgetStyle.radius,
              textStyle: RecipientTagItemWidgetStyle.labelTextStyle,
              padding: PlatformInfo.isWeb
                ? RecipientTagItemWidgetStyle.counterPadding
                : RecipientTagItemWidgetStyle.mobileCounterPadding,
              backgroundColor: AppColor.colorEmailAddressTag,
            )
        ]
      ),
    );
  }

  EdgeInsetsGeometry? get _counterMargin {
    if (PlatformInfo.isWeb) {
      return PlatformInfo.isCanvasKit
        ? RecipientTagItemWidgetStyle.webCounterMargin
        : RecipientTagItemWidgetStyle.webMobileCounterMargin;
    } else {
      return RecipientTagItemWidgetStyle.counterMargin;
    }
  }

  int get countRecipients => currentListEmailAddress.length - collapsedListEmailAddress.length;

  Color _getTagBackgroundColor(bool isSelected) {
    if ((isLatestTagFocused && isLatestEmail) || isSelected) {
      return AppColor.colorItemRecipientSelected;
    } else if (EmailUtils.isEmailAddressValid(currentEmailAddress.emailAddress)) {
      return AppColor.colorEmailAddressTag;
    } else {
      return Colors.white;
    }
  }

  BorderSide _getTagBorderSide(bool isSelected) {
    if ((isLatestTagFocused && isLatestEmail) || isSelected) {
      return const BorderSide(width: 1, color: AppColor.primaryColor);
    } else if (EmailUtils.isEmailAddressValid(currentEmailAddress.emailAddress)) {
      return const BorderSide(width: 1, color: AppColor.colorEmailAddressTag);
    } else {
      return const BorderSide(
        width: 1,
        color: AppColor.colorBorderEmailAddressInvalid
      );
    }
  }

  List<PopupMenuAction<RecipientAction>> _buildListRecipientAction(BuildContext context) {
    return RecipientAction.values
      .map((action) => PopupMenuAction<RecipientAction>(
        name: action.getTitle(context),
        value: action,
        icon: action.getIcon(_imagePaths),
        onSelected: _onSelectRecipientAction,
      ))
      .toList();
  }

  void _onSelectRecipientAction(RecipientAction recipientAction) {
    popBack();
    log('RecipientTagItemWidget::_onSelectRecipientAction: recipientAction = $recipientAction');
    onSelectRecipientAction?.call(recipientAction, prefix, currentEmailAddress);
  }
}