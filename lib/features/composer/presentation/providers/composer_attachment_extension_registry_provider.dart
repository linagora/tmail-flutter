import 'package:core/presentation/extensions/composer_attachment_extension_registry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_uri_value_notifier_provider.dart';
import 'package:workplace/presentation/extension/workplace_composer_attachment_extension.dart';

part 'composer_attachment_extension_registry_provider.g.dart';

@Riverpod(keepAlive: true)
ComposerAttachmentExtensionRegistry composerAttachmentExtensionRegistry(Ref ref) {
  final uriNotifier = ref.watch(driveAttachmentUriValueProvider);
  return ComposerAttachmentExtensionRegistry([
    WorkplaceComposerAttachmentExtension(workplaceUri: uriNotifier),
  ]);
}
