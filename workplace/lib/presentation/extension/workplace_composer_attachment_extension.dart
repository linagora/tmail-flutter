import 'package:core/presentation/extensions/composer_attachment_plugin.dart';
import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/presentation/model/drive_pick_state.dart';
import 'package:workplace/presentation/view/drive_intent_fake_page.dart';
import 'package:workplace/presentation/widget/drive_attachment_context_menu_tile.dart';
import 'package:workplace/presentation/widget/drive_attachment_picker_button.dart';

typedef OnDrivePickStateChanged = void Function(String composerId, DrivePickState state);

class WorkplaceComposerAttachmentExtension implements ComposerAttachmentPlugin {
  final ValueListenable<Uri?> workplaceUri;
  final OnDrivePickStateChanged? onPickState;

  const WorkplaceComposerAttachmentExtension({
    required this.workplaceUri,
    this.onPickState,
  });

  Future<WorkplaceIntent?> _fetchIntent(
    Uri workplaceUrl, {
    required String addAsLinkTitle,
  }) async =>
      WorkplaceIntent(
        intentId: 'debug',
        intentUrl: DriveIntentFakePage.buildDataUri('debug'),
      );

  @override
  Widget buildToolbarButton(
    BuildContext context, {
    required String composerId,
    required ImagePaths imagePaths,
    ComposerToolbarButtonStyle style = const ComposerToolbarButtonStyle(),
  }) {
    return ValueListenableBuilder<Uri?>(
      valueListenable: workplaceUri,
      builder: (_, uri, __) {
        if (uri == null) return const SizedBox.shrink();
        return DriveAttachmentPickerButton(
          composerId: composerId,
          imagePaths: imagePaths,
          workplaceUri: uri,
          style: style,
          onPickCallback: onPickState == null
              ? null
              : (state) => onPickState!(composerId, state),
          onFetchIntent: ({required addAsLinkTitle}) =>
              _fetchIntent(uri, addAsLinkTitle: addAsLinkTitle),
        );
      },
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
      builder: (_, uri, __) {
        if (uri == null) return const SizedBox.shrink();
        return DriveAttachmentContextMenuTile(
          composerId: composerId,
          imagePaths: imagePaths,
          workplaceUri: uri,
          label: label,
          onPickCallback: onPickState == null
              ? null
              : (state) => onPickState!(composerId, state),
          onFetchIntent: ({required addAsLinkTitle}) =>
              _fetchIntent(uri, addAsLinkTitle: addAsLinkTitle),
        );
      },
    );
  }
}
