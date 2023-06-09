import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class SendingQueueMailboxWidget extends StatelessWidget {

  final List<SendingEmail> listSendingEmails;
  final bool isSelected;
  final VoidCallback? onOpenSendingQueueAction;

  const SendingQueueMailboxWidget({
    super.key,
    required this.listSendingEmails,
    this.isSelected = false,
    this.onOpenSendingQueueAction
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = Get.find<ImagePaths>();
    final responsiveUtils = Get.find<ResponsiveUtils>();

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpenSendingQueueAction,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? AppColor.colorBgMailboxSelected : Colors.transparent),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: responsiveUtils.isLandscapeMobile(context) ? 20 : 28),
                    SvgPicture.asset(
                      imagePath.icMailboxSendingQueue,
                      width: PlatformInfo.isWeb ? 20 : 24,
                      height: PlatformInfo.isWeb ? 20 : 24,
                      colorFilter: AppColor.primaryColor.asFilter(),
                      fit: BoxFit.fill),
                    const SizedBox(width: 12),
                    Expanded(child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).sendingQueue,
                            maxLines: 1,
                            softWrap: CommonTextStyle.defaultSoftWrap,
                            overflow: CommonTextStyle.defaultTextOverFlow,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColor.colorNameEmail,
                              fontWeight: FontWeight.normal),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            right: AppUtils.isDirectionRTL(context) ? 0 : 12,
                            left: AppUtils.isDirectionRTL(context) ? 12 : 0,
                          ),
                          child: Text(
                            _getCountSendingEmails(),
                            maxLines: 1,
                            overflow: CommonTextStyle.defaultTextOverFlow,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.normal
                            )
                          ),
                        )
                      ],
                    ))
                  ]
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }

  String _getCountSendingEmails() {
    if (listSendingEmails.isEmpty) {
      return '';
    }
    return listSendingEmails.length <= 999 ? '${listSendingEmails.length}' : '999+';
  }
}