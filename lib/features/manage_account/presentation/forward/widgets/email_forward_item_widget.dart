import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/recipient_forward.dart';

class EmailForwardItemWidget extends StatelessWidget {

  final _imagePaths = Get.find<ImagePaths>();
  final _emailForwardController = Get.find<ForwardController>();

  final RecipientForward recipientForward;
  final SelectMode selectionMode;
  final bool isLast;

  EmailForwardItemWidget({
    Key? key,
    required this.recipientForward,
    this.isLast = false,
    this.selectionMode = SelectMode.INACTIVE,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _emailForwardController.selectRecipientForward(recipientForward),
      onTap: () {
        if (selectionMode == SelectMode.ACTIVE) {
          _emailForwardController.selectRecipientForward(recipientForward);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: recipientForward.selectMode == SelectMode.ACTIVE
            ? AppColor.colorItemEmailSelectedDesktop
            : Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: isLast ? const Radius.circular(12) : Radius.zero,
            bottomRight: isLast ? const Radius.circular(12) : Radius.zero,
          )
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            width: 54,
            height: 54,
            color: Colors.transparent,
            alignment: Alignment.center,
            child: _buildAvatarIcon()
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recipientForward.emailAddress.displayName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    recipientForward.emailAddress.displayName,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black
                    )
                  ),
                ),
              Text(
                recipientForward.emailAddress.email ?? '',
                overflow: CommonTextStyle.defaultTextOverFlow,
                softWrap: CommonTextStyle.defaultSoftWrap,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColor.colorContentEmail
                )
              )
            ],
          )),
          const SizedBox(width: 12),
          buildIconWeb(
            icon: SvgPicture.asset(
              _imagePaths.icDeleteEmailForward,
              fit: BoxFit.fill,
              width: 18,
              height: 18,
            ),
            onTap: () => _emailForwardController.deleteRecipients(
              context,
              recipientForward.emailAddress.email ?? ''
            )
          ),
        ]),
      ),
    );
  }

  Widget _buildAvatarIcon() {
    if (selectionMode == SelectMode.ACTIVE) {
      return Container(
        alignment: Alignment.center,
        child: SvgPicture.asset(
          recipientForward.selectMode == SelectMode.ACTIVE
            ? _imagePaths.icSelected
            : _imagePaths.icUnSelected,
          width: 24,
          height: 24
        )
      );
    } else {
      return (AvatarBuilder()
        ..text(recipientForward.emailAddress.asString().firstLetterToUpperCase)
        ..size(54)
        ..addTextStyle(const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white))
        ..avatarColor(recipientForward.emailAddress.avatarColors)
      ).build();
    }
  }
}
