import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/extensions/composer_attachment_plugin.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';

class ComposerAttachmentExtensionRegistry {
  final List<ComposerAttachmentPlugin> extensions;

  const ComposerAttachmentExtensionRegistry(this.extensions);

  List<Widget> buildToolbarButtons(
    BuildContext context, {
    required String composerId,
    required ImagePaths imagePaths,
    ComposerToolbarButtonStyle style = const ComposerToolbarButtonStyle(),
  }) => extensions
      .map(
        (e) => e.buildToolbarButton(
          context,
          composerId: composerId,
          imagePaths: imagePaths,
          style: style,
        ),
      )
      .toList();

  List<Widget> buildContextMenuTiles(
    BuildContext context, {
    required String composerId,
    required ImagePaths imagePaths,
    required String label,
  }) => extensions
      .map(
        (e) => e.buildContextMenuTile(
          context,
          composerId: composerId,
          imagePaths: imagePaths,
          label: label,
        ),
      )
      .toList();
}
