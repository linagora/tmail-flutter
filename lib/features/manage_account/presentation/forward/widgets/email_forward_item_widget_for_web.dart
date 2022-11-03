import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/utils/utils.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/recipient_forward.dart';

class EmailForwardItemWidget extends StatefulWidget {

  final RecipientForward recipientForward;
  final SelectMode selectionMode;
  final bool isLast;

  const EmailForwardItemWidget({
    Key? key,
    required this.recipientForward,
    this.isLast = false,
    this.selectionMode = SelectMode.INACTIVE,
  }) : super(key: key);

  @override
  State<EmailForwardItemWidget> createState() => _EmailForwardItemWidgetState();
}

class _EmailForwardItemWidgetState extends State<EmailForwardItemWidget> {
  final _imagePaths = Get.find<ImagePaths>();

  final _emailForwardController = Get.find<ForwardController>();

  bool isHoverIcon = false;
  bool isHoverItem = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {},
      onHover: (value) {
        setState(mounted, this.setState, () {
          isHoverItem = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.recipientForward.selectMode == SelectMode.ACTIVE
            ? AppColor.colorItemEmailSelectedDesktop
            : Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: widget.isLast ? const Radius.circular(12) : Radius.zero,
            bottomRight: widget.isLast ? const Radius.circular(12) : Radius.zero,
          )
        ),
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
              width: 54,
              height: 54,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: _buildAvatarIcon()
            )
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.recipientForward.emailAddress.displayName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    widget.recipientForward.emailAddress.displayName,
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
                widget.recipientForward.emailAddress.email ?? '',
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
          if (isHoverItem)
            buildIconWeb(
              icon: SvgPicture.asset(
                _imagePaths.icDeleteEmailForward,
                fit: BoxFit.fill,
                width: 18,
                height: 18,
              ),
              onTap: () => _emailForwardController.deleteRecipients(
                context,
                widget.recipientForward.emailAddress.email ?? ''
              )
            ),
        ]),
      ),
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
      return (AvatarBuilder()
        ..text(widget.recipientForward.emailAddress.asString().firstLetterToUpperCase)
        ..size(54)
        ..addTextStyle(const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white))
        ..avatarColor(widget.recipientForward.emailAddress.avatarColors)
      ).build();
    }
  }
}
