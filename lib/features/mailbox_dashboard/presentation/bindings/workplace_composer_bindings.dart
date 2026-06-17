import 'package:core/presentation/extensions/composer_attachment_extension_registry.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_uri_value_notifier_provider.dart';
import 'package:workplace/presentation/extension/workplace_composer_attachment_extension.dart';

class WorkplaceComposerBindings {
  void dependencies() {
    final uriNotifier = appProviderContainer.read(driveAttachmentUriValueProvider);
    Get.lazyPut<ComposerAttachmentExtensionRegistry>(
      () => ComposerAttachmentExtensionRegistry([
        WorkplaceComposerAttachmentExtension(workplaceUri: uriNotifier),
      ]),
    );
  }
}
