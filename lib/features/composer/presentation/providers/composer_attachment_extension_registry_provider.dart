import 'package:core/presentation/extensions/composer_attachment_extension_registry.dart';
import 'package:core/utils/app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_uri_value_notifier_provider.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:workplace/presentation/extension/workplace_composer_attachment_extension.dart';
import 'package:workplace/presentation/model/drive_pick_state.dart';

part 'composer_attachment_extension_registry_provider.g.dart';

@Riverpod(keepAlive: true)
ComposerAttachmentExtensionRegistry composerAttachmentExtensionRegistry(Ref ref) {
  final uriNotifier = ref.watch(driveAttachmentUriValueProvider);
  return ComposerAttachmentExtensionRegistry([
    WorkplaceComposerAttachmentExtension(
      workplaceUri: uriNotifier,
      // Read at picker-open time, so it's always the current session's answer.
      uploadFromUrlSupported: () {
        final dashboard = getBinding<MailboxDashBoardController>();
        final jmapUrl = dashboard?.dynamicUrlInterceptors.jmapUrl;
        if (jmapUrl == null || jmapUrl.isEmpty) return false;
        return dashboard?.sessionCurrent?.isUploadFromUrlSupported(
              dashboard.accountId.value,
              jmapUrl: jmapUrl,
            ) ??
            false;
      },
      oidcTokenGetter: () => getBinding<AuthorizationInterceptors>()?.currentOidcIdToken,
      maxAttachmentSizeBytesGetter: () =>
          getBinding<MailboxDashBoardController>()?.maxSizeAttachmentsPerEmail?.value,
      // Read at picker-open time from the composer that owns the picker.
      remainingAttachmentCapacityBytesGetter: (composerId) =>
          getBinding<ComposerController>(tag: composerId)
              ?.attachmentUploadValidationService
              .remainingCapacityBytes,
      onPickState: (composerId, state) async {
        if (state is DrivePickResult) {
          final composer = getBinding<ComposerController>(tag: composerId);
          if (composer == null) {
            // Composer closed or wrong tag — the pick has nowhere to land.
            logError('ComposerAttachmentExtensionRegistry::onPickState: no ComposerController for tag=$composerId, drive pick discarded');
            getBinding<ToastManager>()?.showMessageFailure(
              DrivePickFailure(Exception('ComposerController unavailable')),
            );
            return;
          }
          // No catch here: handleDrivePickResult swallows and toasts its own errors.
          await composer.handleDrivePickResult(state.documents);
        } else if (state is DrivePickFailure) {
          getBinding<ToastManager>()?.showMessageFailure(state);
        }
      },
    ),
  ]);
}
