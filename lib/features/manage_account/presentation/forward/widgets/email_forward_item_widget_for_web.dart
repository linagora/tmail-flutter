import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/utils/utils.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/recipient_forward.dart';

class EmailForwardItemWidget extends StatefulWidget {

  final RecipientForward recipientForward;
  final SelectMode selectionMode;

  const EmailForwardItemWidget({
    Key? key,
    required this.recipientForward,
    this.selectionMode = SelectMode.INACTIVE,
  }) : super(key: key);

  @override
  State<EmailForwardItemWidget> createState() => _EmailForwardItemWidgetState();
}

class _EmailForwardItemWidgetState extends State<EmailForwardItemWidget> {
  final _imagePaths = Get.find<ImagePaths>();

  final _emailForwardController = Get.find<ForwardController>();

  bool isHoverIcon = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.white,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        InkWell(
          onTap: () {
            if (isHoverIcon) {
              _emailForwardController.selectRecipientForward(widget.recipientForward);
            }
          },
          onHover: (value) {
            setState(mounted, this.setState, () {
              isHoverIcon = value;
            });
          },
          child: Container(
              width: 32,
              height: 32,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: _buildAvatarIcon())),
        const SizedBox(width: 10),
        Expanded(child: Text(widget.recipientForward.emailAddress,
            overflow: CommonTextStyle.defaultTextOverFlow,
            softWrap: CommonTextStyle.defaultSoftWrap,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black))),
        buildIconWeb(
            icon: SvgPicture.asset(
              _imagePaths.icDeleteEmailForward,
              fit: BoxFit.fill,
              width: 18,
              height: 18,
            ),
            onTap: () =>
                _emailForwardController.deleteRecipients(context, widget.recipientForward.emailAddress)),
      ]),
    );
  }

  Widget _buildAvatarIcon() {
    if (isHoverIcon || widget.recipientForward.selectMode == SelectMode.ACTIVE) {
      return Container(
          alignment: Alignment.center,
          child: SvgPicture.asset(
              widget.recipientForward.selectMode == SelectMode.ACTIVE
                  ? _imagePaths.icSelected
                  : _imagePaths.icUnSelected,
              width: 24,
              height: 24));
    } else {
      return CircleAvatar(
          backgroundColor: AppColor.colorTextButton,
          radius: 16,
          child: Text(widget.recipientForward.emailAddress[0].toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)));
    }
  }
}
