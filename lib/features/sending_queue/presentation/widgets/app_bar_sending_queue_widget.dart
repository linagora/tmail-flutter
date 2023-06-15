
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/utils/sending_queue_utils.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AppBarSendingQueueWidget extends StatelessWidget {

  final VoidCallback? onBackAction;
  final VoidCallback? onOpenMailboxMenu;
  final SelectMode selectMode;
  final List<SendingEmail> listSendingEmailSelected;

  const AppBarSendingQueueWidget({
    super.key,
    required this.listSendingEmailSelected,
    this.onBackAction,
    this.onOpenMailboxMenu,
    this.selectMode = SelectMode.INACTIVE
  });

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();

    return LayoutBuilder(builder: (context, constraints) {
      log('AppBarSendingQueueWidget::build(): MAX_WIDTH: ${constraints.maxWidth}');
      return Container(
        height: 52,
        color: Colors.white,
        padding: SendingQueueUtils.getPaddingAppBarByResponsiveSize(constraints.maxWidth),
        child: Row(
          children: [
            if (selectMode == SelectMode.INACTIVE)
              buildIconWeb(
                icon: SvgPicture.asset(
                  imagePaths.icMenuMailbox,
                  colorFilter: AppColor.colorTextButton.asFilter(),
                  fit: BoxFit.fill
                ),
                tooltip: AppLocalizations.of(context).openMailboxMenu,
                onTap: onOpenMailboxMenu
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  child: InkWell(
                    onTap: onBackAction,
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            DirectionUtils.isDirectionRTLByLanguage(context) ? imagePaths.icCollapseFolder : imagePaths.icBack,
                            colorFilter: AppColor.colorTextButton.asFilter(),
                            fit: BoxFit.fill
                          ),
                          const SizedBox(width: 8),
                          Text(
                            listSendingEmailSelected.length.toString(),
                            maxLines: 1,
                            overflow: CommonTextStyle.defaultTextOverFlow,
                            softWrap: CommonTextStyle.defaultSoftWrap,
                            style: const TextStyle(
                              fontSize: 17,
                              color: AppColor.colorTextButton
                            )
                          )
                        ]
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(child: Text(
              AppLocalizations.of(context).sendingQueue,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: CommonTextStyle.defaultTextOverFlow,
              softWrap: CommonTextStyle.defaultSoftWrap,
              style: const TextStyle(
                fontSize: 21,
                color: Colors.black,
                fontWeight: FontWeight.bold
              )
            )),
            const SizedBox(width: 50)
          ],
        ),
      );
    });
  }
}