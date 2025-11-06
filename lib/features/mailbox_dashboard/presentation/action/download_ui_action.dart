import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';

class DownloadUIAction extends UIAction {
  static final idle = DownloadUIAction();

  DownloadUIAction() : super();

  @override
  List<Object?> get props => [];
}

class UpdateAttachmentsViewStateAction extends DownloadUIAction {
  UpdateAttachmentsViewStateAction(this.blobId, this.viewState);

  final Id? blobId;
  final Either<Failure, Success> viewState;

  @override
  List<Object?> get props => [blobId, viewState];
}

class OpenComposerFromMailtoLinkAction extends DownloadUIAction {
  OpenComposerFromMailtoLinkAction(this.uri);

  final Uri uri;

  @override
  List<Object?> get props => [uri];
}
