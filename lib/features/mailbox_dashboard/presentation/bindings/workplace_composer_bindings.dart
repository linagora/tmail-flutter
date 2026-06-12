import 'package:core/presentation/extensions/composer_attachment_extension_registry.dart';
import 'package:get/get.dart';
import 'package:workplace/presentation/extension/workplace_composer_attachment_extension.dart';

class WorkplaceComposerBindings {
  void dependencies() {
    Get.lazyPut<ComposerAttachmentExtensionRegistry>(
      () => const ComposerAttachmentExtensionRegistry([
        WorkplaceComposerAttachmentExtension(),
      ]),
    );
  }
}
