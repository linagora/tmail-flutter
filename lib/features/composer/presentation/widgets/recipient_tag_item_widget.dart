import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/avatar/gradient_circle_avatar_icon.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/recipient_tag_item_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';

class RecipientTagItemWidget extends StatelessWidget {

  final bool isCollapsed;
  final bool isLatestTagFocused;
  final bool isLatestEmail;
  final PrefixEmailAddress prefix;
  final EmailAddress currentEmailAddress;
  final List<EmailAddress> currentListEmailAddress;
  final List<EmailAddress> collapsedListEmailAddress;
  final OnShowFullListEmailAddressAction? onShowFullAction;
  final VoidCallback? onDeleteTagAction;

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
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            top: PlatformInfo.isWeb ? 8 : 0,
            end: isCollapsed ? 40 : 0),
          child: InkWell(
            onTap: () => isCollapsed
              ? onShowFullAction?.call(prefix)
              : null,
            child: Chip(
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
              deleteIcon: SvgPicture.asset(_imagePaths.icClose, fit: BoxFit.fill),
              labelStyle: RecipientTagItemWidgetStyle.labelTextStyle,
              backgroundColor: _getTagBackgroundColor(),
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(RecipientTagItemWidgetStyle.radius)),
                side: _getTagBorderSide(),
              ),
              avatar: currentEmailAddress.displayName.isNotEmpty
                ? GradientCircleAvatarIcon(
                    colors: currentEmailAddress.avatarColors,
                    label: currentEmailAddress.displayName.firstLetterToUpperCase,
                    labelFontSize: 10,
                    iconSize: 24,
                  )
                : null,
              onDeleted: onDeleteTagAction,
            )
          ),
        ),
        if (isCollapsed)
          TMailButtonWidget.fromText(
            margin: RecipientTagItemWidgetStyle.counterMargin,
            text: '+${currentListEmailAddress.length - collapsedListEmailAddress.length}',
            onTapActionCallback: () => onShowFullAction?.call(prefix),
            borderRadius: RecipientTagItemWidgetStyle.radius,
            textStyle: RecipientTagItemWidgetStyle.labelTextStyle,
            padding: RecipientTagItemWidgetStyle.counterPadding,
            backgroundColor: AppColor.colorEmailAddressTag,
          )
      ]
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