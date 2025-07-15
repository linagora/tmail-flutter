
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/state/button_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_action_type.dart';

typedef OnHandleSendingEmailActionType = void Function(SendingEmailActionType, List<SendingEmail>);

class BottomBarSendingQueueWidget extends StatelessWidget {

  final List<SendingEmail> listSendingEmailSelected;
  final OnHandleSendingEmailActionType? onHandleSendingEmailActionType;

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  BottomBarSendingQueueWidget({
    super.key,
    required this.listSendingEmailSelected,
    this.onHandleSendingEmailActionType
  });

  @override
  Widget build(BuildContext context) {
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
              icon: _imagePaths.icEdit,
              borderRadius: 0,
              backgroundColor: Colors.transparent,
              iconColor: SendingEmailActionType.edit.getButtonIconColor(_canEditable ? ButtonState.enabled : ButtonState.disabled),
              textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontSize: 12,
                color: SendingEmailActionType.edit.getButtonTitleColor(_canEditable ? ButtonState.enabled : ButtonState.disabled)
              ),
              verticalDirection: _responsiveUtils.isPortraitMobile(context),
              onTapActionCallback: () {
                if (_canEditable) {
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
              icon: _imagePaths.icRefresh,
              borderRadius: 0,
              backgroundColor: Colors.transparent,
              iconColor: SendingEmailActionType.resend.getButtonIconColor(_canResend ? ButtonState.enabled : ButtonState.disabled),
              textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontSize: 12,
                color: SendingEmailActionType.resend.getButtonTitleColor(_canResend ? ButtonState.enabled : ButtonState.disabled)
              ),
              verticalDirection: _responsiveUtils.isPortraitMobile(context),
              onTapActionCallback: () {
                if (_canResend) {
                  onHandleSendingEmailActionType?.call(SendingEmailActionType.resend, listSendingEmailSelected);
                }
              },
            ),
          ),
          Expanded(
            child: TMailButtonWidget(
              key: Key(SendingEmailActionType.delete.getButtonKey()),
              text: SendingEmailActionType.delete.getButtonTitle(context),
              icon: _imagePaths.icDeleteComposer,
              borderRadius: 0,
              backgroundColor: Colors.transparent,
              iconColor: SendingEmailActionType.delete.getButtonIconColor(ButtonState.enabled),
              textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontSize: 12,
                color: SendingEmailActionType.delete.getButtonTitleColor(ButtonState.enabled)
              ),
              verticalDirection: _responsiveUtils.isPortraitMobile(context),
              onTapActionCallback: () => onHandleSendingEmailActionType?.call(SendingEmailActionType.delete, listSendingEmailSelected),
            ),
          ),
        ],
      ),
    );
  }

  bool get _canEditable {
    if (PlatformInfo.isMobile) {
      return listSendingEmailSelected.length == 1 &&
        listSendingEmailSelected.first.isEditableSupported;
    } else {
      return false;
    }
  }

  bool get _canResend {
    if (PlatformInfo.isMobile) {
      return listSendingEmailSelected.length == 1 &&
        (listSendingEmailSelected.first.isWaiting ||
          listSendingEmailSelected.first.isError ||
          listSendingEmailSelected.first.isCanceled);
    } else {
      return false;
    }
  }
}