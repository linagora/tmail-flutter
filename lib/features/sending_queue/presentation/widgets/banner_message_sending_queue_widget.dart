
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/utils/sending_queue_utils.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class BannerMessageSendingQueueWidget extends StatelessWidget {

  const BannerMessageSendingQueueWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final imagePath = getBinding<ImagePaths>();

    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        margin: SendingQueueUtils.getMarginBannerMessageByResponsiveSize(constraints.maxWidth),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColor.colorBannerMessageSendingQueue,
          borderRadius: BorderRadius.all(Radius.circular(8))
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              imagePath!.icMailboxSendingQueue,
              fit: BoxFit.fill,
              width: 20,
              height: 20,
              colorFilter: AppColor.colorTitleSendingItem.asFilter(),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(
              AppLocalizations.of(context).bannerMessageSendingQueueViewOnIOS,
              style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.normal
              )
            ))
          ]
        ),
      );
    });
  }
}