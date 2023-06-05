
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/button_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_action_type.dart';

typedef OnHandleSendingEmailActionType = void Function(SendingEmailActionType, List<SendingEmail>);

class BottomBarSendingQueueWidget extends StatelessWidget {

  final List<SendingEmail> listSendingEmails;
  final OnHandleSendingEmailActionType? onHandleSendingEmailActionType;

  const BottomBarSendingQueueWidget({
    super.key,
    required this.listSendingEmails,
    this.onHandleSendingEmailActionType,
  });

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(
          color: AppColor.lineItemListColor,
          width: 0.2,
        )),
        color: Colors.white
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: (ButtonBuilder(imagePaths.icDeleteComposer)
            ..key(Key(SendingEmailActionType.delete.getButtonKey()))
            ..iconColor(SendingEmailActionType.delete.getButtonIconColor())
            ..padding(const EdgeInsets.all(8))
            ..radiusSplash(8)
            ..textStyle(TextStyle(fontSize: 12, color: SendingEmailActionType.delete.getButtonTitleColor()))
            ..onPressActionClick(() => onHandleSendingEmailActionType?.call(SendingEmailActionType.delete, listSendingEmails))
            ..text(SendingEmailActionType.delete.getButtonTitle(context), isVertical: true)
          ).build())
        ],
      ),
    );
  }
}