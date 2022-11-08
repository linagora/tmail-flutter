import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/recipient_forward.dart';

typedef OnSelectRecipientCallbackAction = Function(RecipientForward recipientForward);
typedef OnDeleteRecipientCallbackAction = Function(RecipientForward recipientForward);

class EmailForwardItemWidget extends StatelessWidget {

  final RecipientForward recipientForward;
  final SelectMode selectionMode;
  final OnSelectRecipientCallbackAction? onSelectRecipientCallback;
  final OnDeleteRecipientCallbackAction? onDeleteRecipientCallback;

  const EmailForwardItemWidget(this.recipientForward, {
    Key? key,
    this.selectionMode = SelectMode.INACTIVE,
    this.onSelectRecipientCallback,
    this.onDeleteRecipientCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _imagePaths = Get.find<ImagePaths>();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onLongPress: () {
            if (!BuildUtils.isWeb) {
              onSelectRecipientCallback?.call(recipientForward);
            }
          },
          customBorder: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Container(
            padding: const EdgeInsets.only(left: 12, bottom: 12, top: 12),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.all(Radius.circular(
                recipientForward.selectMode == SelectMode.ACTIVE ? 12 : 0))
            ),
            child: Row(children: [
              _buildAvatarIcon(_imagePaths),
              const SizedBox(width: 12),
              Expanded(child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipientForward.emailAddress.asString(),
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black
                    )
                  ),
                  if (recipientForward.emailAddress.displayName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        recipientForward.emailAddress.email ?? '',
                        overflow: CommonTextStyle.defaultTextOverFlow,
                        softWrap: CommonTextStyle.defaultSoftWrap,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColor.colorContentEmail
                        )
                      ),
                    )
                ],
              )),
              const SizedBox(width: 12),
              if (selectionMode == SelectMode.INACTIVE)
                buildIconWeb(
                  iconSize: 30,
                  splashRadius: 20,
                  icon: SvgPicture.asset(_imagePaths.icDeleteRecipient),
                  onTap: () => onDeleteRecipientCallback?.call(recipientForward)
                )
            ]),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (recipientForward.selectMode == SelectMode.ACTIVE) {
      return AppColor.colorItemRecipientSelected;
    } else {
      return Colors.transparent;
    }
  }

  Widget _buildAvatarIcon(ImagePaths imagePaths) {
    if (recipientForward.selectMode == SelectMode.ACTIVE) {
      return InkWell(
        customBorder: const CircleBorder(),
        onTap: () => onSelectRecipientCallback?.call(recipientForward),
        child: Container(
          width: 40,
          height: 40,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: SvgPicture.asset(
            imagePaths.icSelectedRecipient,
            width: 40,
            height: 40,
            fit: BoxFit.fill,
          ),
        ),
      );
    } else {
      return (AvatarBuilder()
        ..text(recipientForward.emailAddress.asString().firstLetterToUpperCase)
        ..size(40)
        ..addTextStyle(const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.white))
        ..avatarColor(recipientForward.emailAddress.avatarColors)
        ..addOnTapActionClick(() => onSelectRecipientCallback?.call(recipientForward))
      ).build();
    }
  }
}
