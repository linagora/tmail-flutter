import 'package:core/presentation/extensions/composer_attachment_extension_registry.dart';
import 'package:core/utils/app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_access_token_notifier.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_notifier.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_uri_value_notifier_provider.dart';
import 'package:tmail_ui_user/main/providers/workplace/workplace_fqdn_notifier.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:workplace/presentation/notifier/drive_attachment_state.dart';
import 'package:workplace/presentation/extension/workplace_composer_attachment_extension.dart';

part 'composer_attachment_extension_registry_provider.g.dart';

@Riverpod(keepAlive: true)
ComposerAttachmentExtensionRegistry composerAttachmentExtensionRegistry(Ref ref) {
  final uriNotifier = ref.watch(driveAttachmentUriValueProvider);
  return ComposerAttachmentExtensionRegistry([
    WorkplaceComposerAttachmentExtension(
      workplaceUri: uriNotifier,
      onPickResult: (composerId, result) {
        try {
          getBinding<ComposerController>(
            tag: composerId,
          )?.handleDrivePickResult(result);
        } catch (e) {
          logWarning('ComposerAttachmentExtensionRegistry::onPickResult: $e');
        }
      },
      onFetchIntent: (composerId, {required addAsLink, required addAsAttachment}) async {
        try {
          final token = await ref.read(driveAccessTokenProvider.future);
          if (token == null) return null;
          final fqdn = ref.read(workplaceFqdnProvider);
          if (fqdn == null) return null;
          final platformUrl = Uri.parse(fqdn.startsWith('http') ? fqdn : 'https://$fqdn');
          await ref
              .read(driveAttachmentProvider(composerId).notifier)
              .openDrivePicker(
                platformUrl: platformUrl,
                accessToken: token,
                addAsLink: addAsLink,
                addAsAttachment: addAsAttachment,
              );
          final state = ref.read(driveAttachmentProvider(composerId));
          return state is DriveIntentPending ? state.intent : null;
        } catch (e) {
          logWarning('ComposerAttachmentExtensionRegistry::onFetchIntent: $e');
          return null;
        }
      },
    ),
  ]);
}
