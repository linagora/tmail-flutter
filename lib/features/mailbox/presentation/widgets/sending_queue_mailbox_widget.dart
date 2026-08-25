import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SendingQueueMailboxWidget extends StatelessWidget {

  final List<SendingEmail> listSendingEmails;
  final bool isSelected;
  final ImagePaths imagePaths;
  final VoidCallback? onOpenSendingQueueAction;

  const SendingQueueMailboxWidget({
    super.key,
    required this.listSendingEmails,
    required this.imagePaths,
    this.isSelected = false,
    this.onOpenSendingQueueAction,
  });

  @override
  Widget build(BuildContext context) {
    final style = LinagoraSidebarStyle.of(context);

    return LinagoraSidebarItem(
      label: AppLocalizations.of(context).sendingQueue,
      leading: SvgPicture.asset(
        imagePaths.icMailboxSendingQueue,
        width: style.itemIconSize,
        height: style.itemIconSize,
        colorFilter: (isSelected ? style.activeForeground : style.foreground)
            .asFilter(),
        fit: BoxFit.contain,
      ),
      badgeLabel: _sendingEmailCount,
      active: isSelected,
      onTap: onOpenSendingQueueAction,
    );
  }

  String? get _sendingEmailCount {
    if (listSendingEmails.isEmpty) return null;
    return listSendingEmails.length <= 999 ? '${listSendingEmails.length}' : '999+';
  }
}
