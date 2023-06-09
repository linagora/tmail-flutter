
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/button_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/state/button_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_action_type.dart';

typedef OnHandleSendingEmailActionType = void Function(SendingEmailActionType, List<SendingEmail>);

class BottomBarSendingQueueWidget extends StatelessWidget {

  final List<SendingEmail> listSendingEmailSelected;
  final OnHandleSendingEmailActionType? onHandleSendingEmailActionType;
  final bool isConnectedNetwork;

  const BottomBarSendingQueueWidget({
    super.key,
    required this.listSendingEmailSelected,
    this.onHandleSendingEmailActionType,
    this.isConnectedNetwork = true
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
          Expanded(child: (ButtonBuilder(imagePaths.icEdit)
            ..key(Key(SendingEmailActionType.edit.getButtonKey()))
            ..iconColor(SendingEmailActionType.edit.getButtonIconColor(_isEditable ? ButtonState.enabled : ButtonState.disabled))
            ..padding(const EdgeInsets.all(8))
            ..radiusSplash(8)
            ..textStyle(TextStyle(fontSize: 12, color: SendingEmailActionType.edit.getButtonTitleColor(_isEditable ? ButtonState.enabled : ButtonState.disabled)))
            ..onPressActionClick(() {
              if (_isEditable) {
                onHandleSendingEmailActionType?.call(SendingEmailActionType.edit, listSendingEmailSelected);
              }
            })
            ..text(SendingEmailActionType.edit.getButtonTitle(context), isVertical: true)
          ).build()),
          Expanded(child: (ButtonBuilder(imagePaths.icDeleteComposer)
            ..key(Key(SendingEmailActionType.delete.getButtonKey()))
            ..iconColor(SendingEmailActionType.delete.getButtonIconColor(ButtonState.enabled))
            ..padding(const EdgeInsets.all(8))
            ..radiusSplash(8)
            ..textStyle(TextStyle(fontSize: 12, color: SendingEmailActionType.delete.getButtonTitleColor(ButtonState.enabled)))
            ..onPressActionClick(() => onHandleSendingEmailActionType?.call(SendingEmailActionType.delete, listSendingEmailSelected))
            ..text(SendingEmailActionType.delete.getButtonTitle(context), isVertical: true)
          ).build())
        ],
      ),
    );
  }

  bool get _isEditable => !isConnectedNetwork &&
    listSendingEmailSelected.length == 1 &&
    listSendingEmailSelected.first.isWaiting;
}