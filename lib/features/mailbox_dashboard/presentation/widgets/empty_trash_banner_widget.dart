import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/base/widget/clean_messages_banner.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef TrashBannerConfirmCallback =
    void Function(
      BuildContext context,
      MailboxId trashMailboxId,
      WidgetRef ref,
    );

class EmptyTrashBannerWidget extends ConsumerWidget {
  final ResponsiveUtils responsiveUtils;
  final TrashBannerConfirmCallback confirmCallback;
  final MailboxId trashMailboxId;
  final EdgeInsetsGeometry? margin;

  const EmptyTrashBannerWidget({
    super.key,
    required this.trashMailboxId,
    required this.confirmCallback,
    required this.responsiveUtils,
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = AppLocalizations.of(context);
    return CleanMessagesBanner(
      key: const Key('empty_trash_banner'),
      responsiveUtils: responsiveUtils,
      message: appLocalizations.message_delete_all_email_in_trash_button,
      positiveAction: appLocalizations.empty_trash_now,
      margin: margin,
      onPositiveAction: () => confirmCallback(context, trashMailboxId, ref),
    );
  }
}
