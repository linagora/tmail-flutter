import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';

class DownloadUIAction extends UIAction {
  static final idle = DownloadUIAction();

  DownloadUIAction() : super();

  @override
  List<Object?> get props => [];
}

class UpdateAttachmentsViewStateAction extends DownloadUIAction {
  UpdateAttachmentsViewStateAction(this.blobId, this.success);

  final Id? blobId;
  final dynamic success;

  @override
  List<Object?> get props => [blobId, success];
}

class DownloadAttachmentsQuicklyAction extends DownloadUIAction {
  DownloadAttachmentsQuicklyAction(this.attachment);

  final Attachment attachment;

  @override
  List<Object?> get props => [attachment];
}
