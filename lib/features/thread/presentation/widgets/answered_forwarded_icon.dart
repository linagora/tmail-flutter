
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AnsweredForwardedIcon extends StatelessWidget {

  final bool isAnswered;
  final bool isForwarded;
  final ImagePaths imagePaths;

  const AnsweredForwardedIcon({
    super.key,
    required this.isAnswered,
    required this.isForwarded,
    required this.imagePaths
  });

  @override
  Widget build(BuildContext context) {
    final iconString = _getIcon();
    if (iconString.isEmpty) {
      return const SizedBox.shrink();
    }

    final messageToolTip = _getMessageToolTip(context);
    final iconWidget = Padding(
      padding: const EdgeInsets.all(2),
      child: SvgPicture.asset(
        iconString,
        width: 20,
        height: 20,
        colorFilter: AppColor.colorAttachmentIcon.asFilter(),
        fit: BoxFit.fill,
      ),
    );

    if (messageToolTip.isEmpty) {
      return iconWidget;
    } else {
      return MouseRegion(
        cursor: SystemMouseCursors.basic,
        child: Tooltip(
          message: messageToolTip,
          child: iconWidget
        ),
      );
    }
  }

  String _getIcon() {
    if (isAnswered && isForwarded) {
      return imagePaths.icReplyAndForward;
    } else if (isAnswered) {
      return imagePaths.icReply;
    } else if (isForwarded) {
      return imagePaths.icForwarded;
    } else {
      return '';
    }
  }

  String _getMessageToolTip(BuildContext context) {
    if (isAnswered && isForwarded) {
      return AppLocalizations.of(context).repliedAndForwardedMessage;
    } else if (isAnswered) {
      return AppLocalizations.of(context).repliedMessage;
    } else if (isForwarded){
      return AppLocalizations.of(context).forwardedMessage;
    } else {
      return '';
    }
  }
}