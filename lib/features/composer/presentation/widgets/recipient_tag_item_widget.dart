import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/avatar/gradient_circle_avatar_icon.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/text/middle_ellipsis_text.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/base/widget/card_with_smart_interaction_overlay_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/draggable_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/email_address_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/recipient_tag_item_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/edit_recipients_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/draggable_recipient_tag_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

class RecipientTagItemWidget extends StatelessWidget {

  final bool isTagFocused;
  final ImagePaths imagePaths;
  final double? maxWidth;
  final int index;
  final PrefixEmailAddress prefix;
  final EmailAddress currentEmailAddress;
  final List<EmailAddress> currentListEmailAddress;
  final OnDeleteTagAction? onDeleteTagAction;
  final OnEditRecipientAction? onEditRecipientAction;
  final bool isTestingForWeb;
  final String? composerId;
  final bool isMobile;
  final VoidCallback? onClearFocusAction;

  const RecipientTagItemWidget({
    super.key,
    required this.index,
    required this.prefix,
    required this.currentEmailAddress,
    required this.currentListEmailAddress,
    required this.imagePaths,
    @visibleForTesting this.isTestingForWeb = false,
    this.isTagFocused = false,
    this.isMobile = false,
    this.onDeleteTagAction,
    this.onEditRecipientAction,
    this.maxWidth,
    this.composerId,
    this.onClearFocusAction,
  });

  @override
  Widget build(BuildContext context) {
    final overlayWidth = isMobile ? 227.0 : 361.0;
    Widget tagWidget = CardWithSmartInteractionOverlayView(
      overlayWidth: overlayWidth,
      menuBuilder: (onClose) => EditRecipientsView(
        emailAddress: currentEmailAddress,
        imagePaths: imagePaths,
        isMobile: isMobile,
        width: overlayWidth,
        onCopyAction: () {
          if (isMobile) {
            onClose();
          }
          _onEditRecipientAction(
            context,
            EmailAddressActionType.copy,
          );
        },
        onEditAction: () {
          onClose();
          _onEditRecipientAction(
            context,
            EmailAddressActionType.edit,
          );
        },
        onCreateRuleAction: () {
          onClose();
          _onEditRecipientAction(
            context,
            EmailAddressActionType.createRule,
          );
        },
        onCloseAction: onClose,
      ),
      onClearFocusAction: onClearFocusAction,
      child: Container(
        key: Key('recipient_tag_item_${prefix.name}_$index'),
        constraints: const BoxConstraints(maxWidth: 267),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(RecipientTagItemWidgetStyle.radius),
          ),
          border: _getTagBorder(),
          color: _getTagBackgroundColor(),
        ),
        height: 32,
        padding: const EdgeInsetsDirectional.only(start: 8, end: 4),
        margin: PlatformInfo.isMobile
            ? const EdgeInsetsDirectional.only(top: 8)
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GradientCircleAvatarIcon(
              key: Key('avatar_icon_recipient_tag_item_${prefix.name}_$index'),
              colors: currentEmailAddress.avatarColors,
              label: currentEmailAddress.asString().firstCharacterToUpperCase,
              textStyle: RecipientTagItemWidgetStyle.avatarTextStyle,
              iconSize: RecipientTagItemWidgetStyle.avatarIconSize,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: MiddleEllipsisText(
                key: Key('label_recipient_tag_item_${prefix.name}_$index'),
                currentEmailAddress.asString(),
                style: RecipientTagItemWidgetStyle.labelTextStyle,
              ),
            ),
            const SizedBox(width: 4),
            TMailButtonWidget.fromIcon(
              key: Key('delete_icon_recipient_tag_item_${prefix.name}_$index'),
              icon: imagePaths.icClose,
              iconSize: 20,
              iconColor: AppColor.m3SysOutline,
              padding: const EdgeInsets.all(4),
              borderRadius: 100,
              backgroundColor: Colors.transparent,
              onTapActionCallback: () =>
                  onDeleteTagAction?.call(currentEmailAddress),
            )
          ],
        ),
      ),
    );

    if (PlatformInfo.isWeb || isTestingForWeb) {
      tagWidget = MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: tagWidget,
      );
    }

    tagWidget = Draggable<DraggableEmailAddress>(
      data: DraggableEmailAddress(
        emailAddress: currentEmailAddress,
        filterField: prefix.filterField,
        composerId: composerId,
      ),
      feedback: DraggableRecipientTagWidget(
        imagePaths: imagePaths,
        emailAddress: currentEmailAddress,
      ),
      childWhenDragging: PlatformInfo.isMobile
        ? Padding(
            padding: const EdgeInsets.only(top: 10),
            child: DraggableRecipientTagWidget(
              imagePaths: imagePaths,
              emailAddress: currentEmailAddress,
            ),
          )
        : DraggableRecipientTagWidget(
            imagePaths: imagePaths,
            emailAddress: currentEmailAddress,
          ),
      child: tagWidget,
    );

    if ((PlatformInfo.isWeb || isTestingForWeb) && PlatformInfo.isCanvasKit) {
      tagWidget = Padding(
        padding: const EdgeInsetsDirectional.only(top: 8),
        child: tagWidget,
      );
    }

    return tagWidget;
  }

  Color _getTagBackgroundColor() {
    if (isTagFocused) {
      return AppColor.colorItemRecipientSelected;
    } else if (EmailUtils.isValidEmail(currentEmailAddress.emailAddress)) {
      return AppColor.grayBackgroundColor;
    } else {
      return Colors.white;
    }
  }

  Border _getTagBorder() {
    if (isTagFocused) {
      return Border.all(
        width: 1,
        color: AppColor.primaryColor,
      );
    } else if (EmailUtils.isValidEmail(currentEmailAddress.emailAddress)) {
      return Border.all(
        width: 1,
        color: AppColor.grayBackgroundColor,
      );
    } else {
      return Border.all(
        width: 1,
        color: AppColor.colorBorderEmailAddressInvalid,
      );
    }
  }

  void _onEditRecipientAction(
    BuildContext context,
    EmailAddressActionType emailAddressActionType,
  ) {
    onEditRecipientAction?.call(
      context,
      prefix,
      currentEmailAddress,
      emailAddressActionType,
    );
  }
}