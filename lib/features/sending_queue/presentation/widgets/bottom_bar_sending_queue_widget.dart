
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/state/button_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/extensions/list_sending_email_extension.dart';
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
    final responsiveUtils = Get.find<ResponsiveUtils>();

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(
          color: AppColor.colorDividerHorizontal,
          width: 0.5,
        )),
        color: Colors.white
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: TMailButtonWidget(
              key: Key(SendingEmailActionType.edit.getButtonKey()),
              text: SendingEmailActionType.edit.getButtonTitle(context),
              icon: imagePaths.icEdit,
              borderRadius: 8,
              iconColor: SendingEmailActionType.edit.getButtonIconColor(_isEditable ? ButtonState.enabled : ButtonState.disabled),
              textStyle: TextStyle(
                fontSize: 12,
                color: SendingEmailActionType.edit.getButtonTitleColor(_isEditable ? ButtonState.enabled : ButtonState.disabled)
              ),
              verticalDirection: responsiveUtils.isPortraitMobile(context),
              onTapActionCallback: () {
                if (_isEditable) {
                  onHandleSendingEmailActionType?.call(
                    SendingEmailActionType.edit,
                    listSendingEmailSelected
                  );
                }
              },
            ),
          ),
          Expanded(
            child: TMailButtonWidget(
              key: Key(SendingEmailActionType.resend.getButtonKey()),
              text: SendingEmailActionType.resend.getButtonTitle(context),
              icon: imagePaths.icRefresh,
              borderRadius: 8,
              iconColor: SendingEmailActionType.resend.getButtonIconColor(_isCanResend ? ButtonState.enabled : ButtonState.disabled),
              textStyle: TextStyle(
                fontSize: 12,
                color: SendingEmailActionType.resend.getButtonTitleColor(_isCanResend ? ButtonState.enabled : ButtonState.disabled)
              ),
              verticalDirection: responsiveUtils.isPortraitMobile(context),
              onTapActionCallback: () {
                if (_isCanResend) {
                  onHandleSendingEmailActionType?.call(SendingEmailActionType.resend, listSendingEmailSelected);
                }
              },
            ),
          ),
          Expanded(
            child: TMailButtonWidget(
              key: Key(SendingEmailActionType.delete.getButtonKey()),
              text: SendingEmailActionType.delete.getButtonTitle(context),
              icon: imagePaths.icDeleteComposer,
              borderRadius: 8,
              iconColor: SendingEmailActionType.delete.getButtonIconColor(ButtonState.enabled),
              textStyle: TextStyle(
                fontSize: 12,
                color: SendingEmailActionType.delete.getButtonTitleColor(ButtonState.enabled)
              ),
              verticalDirection: responsiveUtils.isPortraitMobile(context),
              onTapActionCallback: () => onHandleSendingEmailActionType?.call(SendingEmailActionType.delete, listSendingEmailSelected),
            ),
          ),
        ],
      ),
    );
  }

  bool get _isEditable => !isConnectedNetwork &&
    listSendingEmailSelected.length == 1 &&
    listSendingEmailSelected.first.isEditableSupported;

  bool get _isCanResend => listSendingEmailSelected.isAllSendingStateError();
}