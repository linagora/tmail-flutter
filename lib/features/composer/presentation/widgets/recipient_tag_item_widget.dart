import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/avatar/gradient_circle_avatar_icon.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/draggable_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/recipient_tag_item_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/draggable_recipient_tag_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

class RecipientTagItemWidget extends StatelessWidget {

  final bool isCollapsed;
  final bool isLatestTagFocused;
  final bool isLatestEmail;
  final ImagePaths imagePaths;
  final double? maxWidth;
  final int index;
  final PrefixEmailAddress prefix;
  final EmailAddress currentEmailAddress;
  final List<EmailAddress> currentListEmailAddress;
  final List<EmailAddress> collapsedListEmailAddress;
  final OnShowFullListEmailAddressAction? onShowFullAction;
  final OnDeleteTagAction? onDeleteTagAction;
  final bool isTestingForWeb;

  const RecipientTagItemWidget({
    super.key,
    required this.index,
    required this.prefix,
    required this.currentEmailAddress,
    required this.currentListEmailAddress,
    required this.collapsedListEmailAddress,
    required this.imagePaths,
    @visibleForTesting this.isTestingForWeb = false,
    this.isCollapsed = false,
    this.isLatestTagFocused = false,
    this.isLatestEmail = false,
    this.onShowFullAction,
    this.onDeleteTagAction,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    Widget tagWidget = Chip(
      labelPadding: EdgeInsetsDirectional.symmetric(
        horizontal: 4,
        vertical: DirectionUtils.isDirectionRTLByHasAnyRtl(currentEmailAddress.asString()) ? 0 : 2
      ),
      padding: EdgeInsets.zero,
      label: Text(
        key: Key('label_recipient_tag_item_${prefix.name}_$index'),
        currentEmailAddress.asString(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
      ),
      deleteIcon: SvgPicture.asset(
        imagePaths.icClose,
        key: Key('delete_icon_recipient_tag_item_${prefix.name}_$index'),
        fit: BoxFit.fill
      ),
      labelStyle: RecipientTagItemWidgetStyle.labelTextStyle,
      backgroundColor: _getTagBackgroundColor(),
      side: _getTagBorderSide(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(RecipientTagItemWidgetStyle.radius)),
      ),
      avatar: currentEmailAddress.displayName.isNotEmpty
        ? GradientCircleAvatarIcon(
            key: Key('avatar_icon_recipient_tag_item_${prefix.name}_$index'),
            colors: currentEmailAddress.avatarColors,
            label: currentEmailAddress.displayName.firstLetterToUpperCase,
            labelFontSize: RecipientTagItemWidgetStyle.avatarLabelFontSize,
            iconSize: RecipientTagItemWidgetStyle.avatarIconSize,
          )
        : null,
      onDeleted: () => onDeleteTagAction?.call(currentEmailAddress),
    );

    if (PlatformInfo.isWeb || isTestingForWeb) {
      tagWidget = Draggable<DraggableEmailAddress>(
        data: DraggableEmailAddress(emailAddress: currentEmailAddress, prefix: prefix),
        feedback: DraggableRecipientTagWidget(emailAddress: currentEmailAddress),
        childWhenDragging: DraggableRecipientTagWidget(emailAddress: currentEmailAddress),
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: tagWidget,
        ),
      );
    }

    if ((PlatformInfo.isWeb || isTestingForWeb) && PlatformInfo.isCanvasKit) {
      tagWidget = Padding(
        padding: const EdgeInsetsDirectional.only(top: 8),
        child: tagWidget,
      );
    }

    return Container(
      key: Key('recipient_tag_item_${prefix.name}_$index'),
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: tagWidget),
          if (isCollapsed)
            TMailButtonWidget.fromText(
              key: Key('counter_recipient_tag_item_${prefix.name}_$index'),
              margin: _counterMargin,
              text: '+$countRecipients',
              onTapActionCallback: () => onShowFullAction?.call(prefix),
              borderRadius: RecipientTagItemWidgetStyle.radius,
              textStyle: RecipientTagItemWidgetStyle.labelTextStyle,
              padding: PlatformInfo.isWeb || isTestingForWeb
                ? RecipientTagItemWidgetStyle.counterPadding
                : RecipientTagItemWidgetStyle.mobileCounterPadding,
              backgroundColor: AppColor.colorEmailAddressTag,
            )
        ]
      ),
    );
  }

  EdgeInsetsGeometry? get _counterMargin {
    if (PlatformInfo.isWeb || isTestingForWeb) {
      return PlatformInfo.isCanvasKit
        ? RecipientTagItemWidgetStyle.webCounterMargin
        : RecipientTagItemWidgetStyle.webMobileCounterMargin;
    } else {
      return RecipientTagItemWidgetStyle.counterMargin;
    }
  }

  int get countRecipients => currentListEmailAddress.length - collapsedListEmailAddress.length;

  Color _getTagBackgroundColor() {
    if (isLatestTagFocused && isLatestEmail) {
      return AppColor.colorItemRecipientSelected;
    } else if (EmailUtils.isEmailAddressValid(currentEmailAddress.emailAddress)) {
      return AppColor.grayBackgroundColor;
    } else {
      return Colors.white;
    }
  }

  BorderSide _getTagBorderSide() {
    if (isLatestTagFocused && isLatestEmail) {
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
}