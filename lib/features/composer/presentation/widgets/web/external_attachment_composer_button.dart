import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_attachment_extension_registry_provider.dart';

class ExternalAttachmentComposerButton extends ConsumerWidget {
  const ExternalAttachmentComposerButton({
    super.key,
    required this.composerId,
    required this.imagePaths,
    required this.style,
  });

  final String composerId;
  final ImagePaths imagePaths;
  final ComposerToolbarButtonStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ref
          .watch(composerAttachmentExtensionRegistryProvider)
          .buildToolbarButtons(
            context,
            composerId: composerId,
            imagePaths: imagePaths,
            style: style,
          ),
    );
  }
}
