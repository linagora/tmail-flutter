import 'package:core/presentation/extensions/composer_attachment_plugin.dart';
import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workplace/data/datasource_impl/workplace_datasource_impl.dart';
import 'package:workplace/data/repository_impl/workplace_repository_impl.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/state/workplace_intent_state.dart';
import 'package:workplace/domain/usecase/create_drive_intent_interactor.dart';
import 'package:workplace/domain/usecase/exchange_drive_token_interactor.dart';
import 'package:workplace/presentation/widget/drive_attachment_context_menu_tile.dart';
import 'package:workplace/presentation/widget/drive_attachment_picker_button.dart';

class WorkplaceComposerAttachmentExtension implements ComposerAttachmentPlugin {
  final ValueListenable<Uri?> workplaceUri;
  final String? Function() oidcTokenGetter;
  final void Function(String composerId, List<DriveDocument> result)? onPickResult;

  late final _dataSource = WorkplaceDataSourceImpl();
  late final _repository = WorkplaceRepositoryImpl(_dataSource);
  late final _createIntentInteractor = CreateDriveIntentInteractor(_repository);
  late final _exchangeTokenInteractor = ExchangeDriveTokenInteractor(_repository);

  WorkplaceComposerAttachmentExtension({
    required this.workplaceUri,
    required this.oidcTokenGetter,
    this.onPickResult,
  });

  Future<WorkplaceIntent?> _fetchIntent(
    Uri platformUrl, {
    required String addAsLink,
    required String addAsAttachment,
  }) async {
    final oidcToken = oidcTokenGetter();
    if (oidcToken == null) return null;
    String? accessToken;
    await for (final either in _exchangeTokenInteractor.execute(platformUrl, oidcToken)) {
      either.fold(
        (failure) => logWarning('WorkplaceComposerAttachmentExtension::_fetchIntent exchange failed: $failure'),
        (success) {
          if (success is ExchangeWorkplaceTokenSuccess) accessToken = success.accessToken;
        },
      );
    }
    if (accessToken == null) return null;
    WorkplaceIntent? intent;
    await for (final either in _createIntentInteractor.execute(
      platformUrl,
      accessToken!,
      addAsLink: addAsLink,
      addAsAttachment: addAsAttachment,
    )) {
      either.fold(
        (failure) => logWarning('WorkplaceComposerAttachmentExtension::_fetchIntent create failed: $failure'),
        (success) {
          if (success is CreateWorkplaceIntentSuccess) intent = success.intent;
        },
      );
    }
    return intent;
  }

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
          onPickResult: onPickResult == null
              ? null
              : (result) => onPickResult!(composerId, result),
          onFetchIntent: ({required addAsLink, required addAsAttachment}) =>
              _fetchIntent(uri, addAsLink: addAsLink, addAsAttachment: addAsAttachment),
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
          onPickResult: onPickResult == null
              ? null
              : (result) => onPickResult!(composerId, result),
          onFetchIntent: ({required addAsLink, required addAsAttachment}) =>
              _fetchIntent(uri, addAsLink: addAsLink, addAsAttachment: addAsAttachment),
        );
      },
    );
  }
}
