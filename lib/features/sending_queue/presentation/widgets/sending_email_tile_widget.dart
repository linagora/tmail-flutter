import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_action_type.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/styles/sending_email_tile_style.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/widgets/sending_state_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnLongPressSendingEmailItemAction = void Function(SendingEmail);
typedef OnSelectSendingEmailItemAction = void Function(SendingEmailActionType, SendingEmail);
typedef OnSelectLeadingSendingEmailItemAction = void Function(SendingEmail);

class SendingEmailTileWidget extends StatelessWidget {

  final SendingEmail sendingEmail;
  final SelectMode selectMode;
  final OnLongPressSendingEmailItemAction? onLongPressAction;
  final OnSelectSendingEmailItemAction? onTapAction;
  final OnSelectLeadingSendingEmailItemAction? onSelectLeadingAction;

  final _imagePaths = Get.find<ImagePaths>();
  
  SendingEmailTileWidget({
    super.key,
    required this.sendingEmail,
    required this.selectMode,
    this.onLongPressAction,
    this.onTapAction,
    this.onSelectLeadingAction,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTapAction?.call(SendingEmailActionType.edit, sendingEmail),
          onLongPress: () => onLongPressAction?.call(sendingEmail),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: SendingEmailTileStyle.getPaddingItemListViewByResponsiveSize(constraints.maxWidth),
                child: Row(
                  crossAxisAlignment: _axisAlignment,
                  children: [
                    if (selectMode == SelectMode.ACTIVE)
                      GestureDetector(
                        child: Container(
                          width: SendingEmailTileStyle.avatarIconSize,
                          height: SendingEmailTileStyle.avatarIconSize,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(SendingEmailTileStyle.avatarIconRadius))
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            sendingEmail.isSelected
                              ? _imagePaths.icSelected
                              : _imagePaths.icUnSelected,
                            fit: BoxFit.fill,
                            width: SendingEmailTileStyle.selectIconSize,
                            height: SendingEmailTileStyle.selectIconSize
                          ),
                        ),
                        onTap: () => onSelectLeadingAction?.call(sendingEmail),
                      )
                    else
                      SvgPicture.asset(
                        sendingEmail.presentationEmail.countRecipients == 1
                          ? sendingEmail.sendingState.getAvatarPersonal(_imagePaths)
                          : sendingEmail.sendingState.getAvatarGroup(_imagePaths),
                        fit: BoxFit.fill,
                        width: SendingEmailTileStyle.avatarIconSize,
                        height: SendingEmailTileStyle.avatarIconSize,
                      ),
                    const SizedBox(width: SendingEmailTileStyle.space),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: TextOverflowBuilder(
                            AppLocalizations.of(context).titleRecipientSendingEmail(sendingEmail.presentationEmail.recipientsName()),
                            style: SendingEmailTileStyle.getTitleTextStyle(sendingEmail.sendingState)
                          )),
                          if (sendingEmail.email.attachments != null && sendingEmail.email.attachments!.isNotEmpty)
                            Padding(
                              padding: SendingEmailTileStyle.attachmentPadding,
                              child: SvgPicture.asset(
                                _imagePaths.icAttachment,
                                width: SendingEmailTileStyle.attachmentIconSize,
                                height: SendingEmailTileStyle.attachmentIconSize,
                                fit: BoxFit.fill
                              )
                            ),
                          Padding(
                            padding: SendingEmailTileStyle.timeCreatedPadding,
                            child: Text(
                              sendingEmail.getCreateTimeAt(Localizations.localeOf(context).toLanguageTag()),
                              maxLines: 1,
                              softWrap: CommonTextStyle.defaultSoftWrap,
                              overflow: CommonTextStyle.defaultTextOverFlow,
                              style: SendingEmailTileStyle.getTimeCreatedTextStyle(sendingEmail.sendingState)
                            )
                          ),
                          if (!ResponsiveUtils.isMatchedMobileWidth(constraints.maxWidth) && _isShowStateLabel)
                            Container(
                              margin: SendingEmailTileStyle.statePadding,
                              width: SendingEmailTileStyle.stateRowWidth,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Spacer(),
                                  SendingStateWidget(
                                    sendingState: sendingEmail.sendingState,
                                    constraints: const BoxConstraints(maxWidth: SendingEmailTileStyle.stateLabelWidth),
                                  )
                                ]
                              )
                            )
                        ]),
                        const SizedBox(height: SendingEmailTileStyle.space),
                        TextOverflowBuilder(
                          sendingEmail.presentationEmail.getEmailTitle(),
                          style: SendingEmailTileStyle.getSubTitleTextStyle(sendingEmail.sendingState)
                        ),
                        if (ResponsiveUtils.isMatchedMobileWidth(constraints.maxWidth) && _isShowStateLabel)
                          Padding(
                            padding: SendingEmailTileStyle.statePaddingMobile,
                            child: SendingStateWidget(sendingState: sendingEmail.sendingState))
                      ]
                    ))
                ]),
              ),
              Padding(
                padding: SendingEmailTileStyle.getPaddingDividerListViewByResponsiveSize(constraints.maxWidth),
                child: const Divider(),
              )
            ],
          ),
        ),
      );
    });
  }

  bool get _isShowStateLabel {
    if (PlatformInfo.isIOS) {
      return !sendingEmail.isWaiting;
    } else {
      return true;
    }
  }

  CrossAxisAlignment get _axisAlignment {
    if (PlatformInfo.isIOS) {
      return _isShowStateLabel ? CrossAxisAlignment.start : CrossAxisAlignment.center;
    } else {
      return CrossAxisAlignment.start;
    }
  }
}