import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/avatar/gradient_circle_avatar_icon.dart';
import 'package:core/presentation/views/text/middle_ellipsis_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';

class DraggableRecipientTagWidget extends StatelessWidget {
  final EmailAddress emailAddress;
  final ImagePaths imagePaths;

  const DraggableRecipientTagWidget({
    super.key,
    required this.emailAddress,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 267),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: AppColor.primaryColor,
        ),
        height: 32,
        padding: const EdgeInsetsDirectional.only(start: 8, end: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GradientCircleAvatarIcon(
              colors: emailAddress.avatarColors,
              label: emailAddress.asString().firstCharacterToUpperCase,
              textStyle: ThemeUtils.textStyleInter500().copyWith(
                color: Colors.white,
                fontSize: 14,
                height: 19.2 / 14,
                letterSpacing: 0.0,
              ),
              iconSize: 20,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: MiddleEllipsisText(
                emailAddress.asString(),
                style: ThemeUtils.textStyleInter400.copyWith(
                  color: Colors.white,
                  fontSize: 17,
                  height: 1.0,
                  letterSpacing: -0.17,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(
                imagePaths.icClose,
                width: 20,
                height: 20,
                colorFilter: AppColor.m3SysOutline.asFilter(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
