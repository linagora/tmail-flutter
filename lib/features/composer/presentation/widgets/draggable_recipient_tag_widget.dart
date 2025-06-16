import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/avatar/gradient_circle_avatar_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/draggable_recipient_tag_widget_style.dart';

class DraggableRecipientTagWidget extends StatelessWidget {

  final EmailAddress emailAddress;
  final EdgeInsetsGeometry? padding;

  final _imagePaths = Get.find<ImagePaths>();

  DraggableRecipientTagWidget({
    super.key,
    required this.emailAddress,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Container(
        decoration: const ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(DraggableRecipientTagWidgetStyle.radius)),
          ),
          color: DraggableRecipientTagWidgetStyle.backgroundColor
        ),
        padding: padding ?? DraggableRecipientTagWidgetStyle.padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emailAddress.displayName.isNotEmpty)
              GradientCircleAvatarIcon(
                colors: emailAddress.avatarColors,
                label: emailAddress.displayName.firstLetterToUpperCase,
                labelFontSize: DraggableRecipientTagWidgetStyle.avatarLabelFontSize,
                iconSize: DraggableRecipientTagWidgetStyle.avatarIconSize,
              ),
            Padding(
              padding: DraggableRecipientTagWidgetStyle.labelPadding,
              child: DefaultTextStyle(
                style: DraggableRecipientTagWidgetStyle.labelTextStyle,
                child: Text(emailAddress.asString()),
              ),
            ),
            SvgPicture.asset(
              _imagePaths.icClose,
              colorFilter: DraggableRecipientTagWidgetStyle.deleteIconColor.asFilter(),
              fit: BoxFit.fill
            )
          ],
        ),
      ),
    );
  }
}