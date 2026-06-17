import 'package:core/presentation/extensions/composer_attachment_plugin.dart';
import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workplace/presentation/widget/drive_attachment_context_menu_tile.dart';
import 'package:workplace/presentation/widget/drive_attachment_picker_button.dart';

class WorkplaceComposerAttachmentExtension implements ComposerAttachmentPlugin {
  final ValueListenable<Uri?> workplaceUri;

  const WorkplaceComposerAttachmentExtension({required this.workplaceUri});

  @override
  Widget buildToolbarButton(
    BuildContext context, {
    required String composerId,
    required ImagePaths imagePaths,
    ComposerToolbarButtonStyle style = const ComposerToolbarButtonStyle(),
  }) {
    return ValueListenableBuilder<Uri?>(
      valueListenable: workplaceUri,
      builder: (_, uri, __) => DriveAttachmentPickerButton(
        composerId: composerId,
        imagePaths: imagePaths,
        workplaceUri: uri,
        style: style,
      ),
    );
  }

  @override
  Widget buildContextMenuTile(
    BuildContext context, {
    required String composerId,
    required ImagePaths imagePaths,
    required String label,
  }) {
    return ValueListenableBuilder<Uri?>(
      valueListenable: workplaceUri,
      builder: (_, uri, __) => DriveAttachmentContextMenuTile(
        composerId: composerId,
        imagePaths: imagePaths,
        workplaceUri: uri,
        label: label,
      ),
    );
  }
}
