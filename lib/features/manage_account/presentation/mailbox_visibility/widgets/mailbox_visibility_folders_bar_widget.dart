import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/expand_mode_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxVisibilityFoldersBarWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final ExpandMode expandMode;
  final VoidCallback onToggleExpandFolder;

  const MailboxVisibilityFoldersBarWidget({
    super.key,
    required this.imagePaths,
    required this.expandMode,
    required this.onToggleExpandFolder,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              appLocalizations.folders,
              style: ThemeUtils.textStyleBodyBody3(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TMailButtonWidget.fromIcon(
            icon: expandMode.getIcon(
              imagePaths,
              DirectionUtils.isDirectionRTLByLanguage(context),
            ),
            iconColor: Colors.black,
            iconSize: 17,
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.all(3),
            tooltipMessage: expandMode.getTooltipMessage(appLocalizations),
            onTapActionCallback: onToggleExpandFolder,
          )
        ],
      ),
    );
  }
}
