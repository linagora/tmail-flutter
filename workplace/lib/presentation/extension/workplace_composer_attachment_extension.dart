import 'package:core/presentation/extensions/composer_attachment_plugin.dart';
import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:workplace/presentation/widget/drive_attachment_context_menu_tile.dart';
import 'package:workplace/presentation/widget/drive_attachment_picker_button.dart';

class WorkplaceComposerAttachmentExtension implements ComposerAttachmentPlugin {
  const WorkplaceComposerAttachmentExtension();

  @override
  Widget buildToolbarButton(
    BuildContext context, {
    required String composerId,
    required ImagePaths imagePaths,
    ComposerToolbarButtonStyle style = const ComposerToolbarButtonStyle(),
  }) {
    return DriveAttachmentPickerButton(
      composerId: composerId,
      imagePaths: imagePaths,
      tooltipLabel: style.tooltipLabel,
      iconColor: style.iconColor,
      iconSize: style.iconSize,
      borderRadius: style.borderRadius,
      padding: style.padding,
      margin: style.margin,
    );
  }

  @override
  Widget buildContextMenuTile(
    BuildContext context, {
    required String composerId,
    required ImagePaths imagePaths,
    required String label,
  }) {
    return DriveAttachmentContextMenuTile(
      composerId: composerId,
      imagePaths: imagePaths,
      label: label,
    );
  }
}
