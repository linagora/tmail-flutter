import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/widget/clean_messages_banner.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef TrashBannerConfirmCallback = void Function(
  BuildContext context,
  PresentationMailbox trashMailbox,
);

class EmptyTrashBannerWidget extends StatelessWidget {
  final ResponsiveUtils responsiveUtils;
  final TrashBannerConfirmCallback confirmCallback;
  final PresentationMailbox trashMailbox;
  final EdgeInsetsGeometry? margin;

  const EmptyTrashBannerWidget({
    super.key,
    required this.trashMailbox,
    required this.confirmCallback,
    required this.responsiveUtils,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return CleanMessagesBanner(
      key: const Key('empty_trash_banner'),
      responsiveUtils: responsiveUtils,
      message: appLocalizations.message_delete_all_email_in_trash_button,
      positiveAction: appLocalizations.empty_trash_now,
      margin: margin,
      onPositiveAction: () => confirmCallback(context, trashMailbox),
    );
  }
}
