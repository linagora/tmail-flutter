import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';

abstract class ComposerAttachmentPlugin {
  Widget buildToolbarButton(
    BuildContext context, {
    required String composerId,
    required ImagePaths imagePaths,
    ComposerToolbarButtonStyle style = const ComposerToolbarButtonStyle(),
  });

  Widget buildContextMenuTile(
    BuildContext context, {
    required String composerId,
    required ImagePaths imagePaths,
    required String label,
  });
}
