import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_action_type.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/utils/sending_queue_utils.dart';
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

  const SendingEmailTileWidget({
    super.key,
    required this.sendingEmail,
    required this.selectMode,
    this.onLongPressAction,
    this.onTapAction,
    this.onSelectLeadingAction,
  });

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();

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
                padding: SendingQueueUtils.getPaddingItemListViewByResponsiveSize(constraints.maxWidth),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectMode == SelectMode.ACTIVE)
                      GestureDetector(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(30))
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            sendingEmail.isSelected
                              ? imagePaths.icSelected
                              : imagePaths.icUnSelected,
                            fit: BoxFit.fill,
                            width: 24,
                            height: 24
                          ),
                        ),
                        onTap: () => onSelectLeadingAction?.call(sendingEmail),
                      )
                    else
                      SvgPicture.asset(
                        sendingEmail.presentationEmail.numberOfAllEmailAddress() == 1
                          ? sendingEmail.sendingState.getAvatarPersonal(imagePaths)
                          : sendingEmail.sendingState.getAvatarGroup(imagePaths),
                        fit: BoxFit.fill,
                        width: 60,
                        height: 60,
                      ),
                    const SizedBox(width: 8),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: TextOverflowBuilder(
                            AppLocalizations.of(context).titleRecipientSendingEmail(sendingEmail.presentationEmail.recipientsName()),
                            style: TextStyle(
                              fontSize: 15,
                              color: sendingEmail.sendingState.getTitleSendingEmailItemColor(),
                              fontWeight: FontWeight.w600
                            )
                          )),
                          if (sendingEmail.email.attachments != null && sendingEmail.email.attachments!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: SvgPicture.asset(
                                imagePaths.icAttachment,
                                width: 20,
                                height: 20,
                                fit: BoxFit.fill
                              )
                            ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              sendingEmail.getCreateTimeAt(Localizations.localeOf(context).toLanguageTag()),
                              maxLines: 1,
                              softWrap: CommonTextStyle.defaultSoftWrap,
                              overflow: CommonTextStyle.defaultTextOverFlow,
                              style: TextStyle(
                                fontSize: 13,
                                color: sendingEmail.sendingState.getTitleSendingEmailItemColor(),
                                fontWeight: FontWeight.normal
                              )
                            )
                          ),
                          if (!ResponsiveUtils.isMatchedMobileWidth(constraints.maxWidth))
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              width: 120,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Spacer(),
                                  SendingStateWidget(
                                    sendingState: sendingEmail.sendingState,
                                    constraints: const BoxConstraints(maxWidth: 80),
                                  )
                                ]
                              )
                            )
                        ]),
                        const SizedBox(height: 8),
                        TextOverflowBuilder(
                          sendingEmail.presentationEmail.getEmailTitle(),
                          style: TextStyle(
                            fontSize: 13,
                            color: sendingEmail.sendingState.getSubTitleSendingEmailItemColor(),
                            fontWeight: FontWeight.normal
                          )
                        ),
                        if (ResponsiveUtils.isMatchedMobileWidth(constraints.maxWidth))
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SendingStateWidget(sendingState: sendingEmail.sendingState))
                      ]
                    ))
                ]),
              ),
              Padding(
                padding: SendingQueueUtils.getPaddingDividerListViewByResponsiveSize(constraints.maxWidth),
                child: const Divider(
                  color: AppColor.lineItemListColor,
                  height: 1,
                  thickness: 0.2
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}