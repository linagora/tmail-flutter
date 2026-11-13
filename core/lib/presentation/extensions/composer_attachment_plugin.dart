import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';

abstract class ComposerAttachmentPlugin {
  /// Notifies when [isAvailable] changes.
  Listenable get availability;

  /// False when [buildToolbarButton] renders nothing; hosts skip its slot.
  bool get isAvailable;

  Widget buildToolbarButton(
    BuildContext context, {
    required String composerId,
    required ImagePaths imagePaths,
    ComposerToolbarButtonStyle style = const ComposerToolbarButtonStyle(),
  });

  /// [onDismiss] closes the host menu; defaults to popping the route (bottom sheet).
  Widget buildContextMenuTile(
    BuildContext context, {
    required ImagePaths imagePaths,
    String? composerId,
    VoidCallback? onDismiss,
  });
}
