import 'package:core/presentation/extensions/composer_attachment_extension_registry.dart';
import 'package:core/utils/app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
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
      oidcTokenGetter: () => getBinding<AuthorizationInterceptors>()?.currentOidcIdToken,
      onPickState: (composerId, state) {
        if (state is DrivePickResult) {
          try {
            getBinding<ComposerController>(tag: composerId)?.handleDrivePickResult(state.documents);
          } catch (e) {
            logWarning('ComposerAttachmentExtensionRegistry::onPickState: $e');
          }
        } else if (state is DrivePickFailure) {
          getBinding<ToastManager>()?.showMessageFailure(state);
        }
      },
    ),
  ]);
}
