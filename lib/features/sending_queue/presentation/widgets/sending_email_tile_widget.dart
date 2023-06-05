import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/composer/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_action_type.dart';
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
    final imagePath = Get.find<ImagePaths>();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTapAction?.call(SendingEmailActionType.edit ,sendingEmail),
        onLongPress: () => onLongPressAction?.call(sendingEmail),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
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
                            ? imagePath.icSelected
                            : imagePath.icUnSelected,
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
                        ? imagePath.icAvatarPersonal
                        : imagePath.icAvatarGroup,
                      fit: BoxFit.fill,
                      width: 60,
                      height: 60,
                    ),
                  const SizedBox(width: 8),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(
                          AppLocalizations.of(context).titleRecipientSendingEmail(sendingEmail.presentationEmail.recipientsName()).withUnicodeCharacter,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColor.colorTitleSendingItem,
                            fontWeight: FontWeight.w600
                          )
                        )),
                        if (sendingEmail.email.attachments != null && sendingEmail.email.attachments!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: SvgPicture.asset(
                              imagePath.icAttachment,
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
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColor.colorTitleSendingItem,
                              fontWeight: FontWeight.normal
                            )
                          )
                        )
                      ]),
                      const SizedBox(height: 8),
                      Text(
                        sendingEmail.presentationEmail.getEmailTitle().withUnicodeCharacter,
                        softWrap: CommonTextStyle.defaultSoftWrap,
                        overflow: CommonTextStyle.defaultTextOverFlow,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColor.colorTitleSendingItem,
                          fontWeight: FontWeight.normal
                        )
                      ),
                    ]
                  ))
              ]),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 84, right: 8),
              child: Divider(
                color: AppColor.lineItemListColor,
                height: 1,
                thickness: 0.2
              ),
            )
          ],
        ),
      ),
    );
  }
}