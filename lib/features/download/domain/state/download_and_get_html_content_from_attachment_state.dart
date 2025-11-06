import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/download/domain/model/download_source_view.dart';

class DownloadAndGettingHtmlContentFromAttachment extends LoadingState {
  DownloadAndGettingHtmlContentFromAttachment({
    required this.blobId,
    this.sourceView,
  });

  final Id? blobId;
  final DownloadSourceView? sourceView;

  @override
  List<Object?> get props => [blobId, sourceView];
}

class DownloadAndGetHtmlContentFromAttachmentSuccess extends UIState {
  DownloadAndGetHtmlContentFromAttachmentSuccess({
    required this.sanitizedHtmlContent,
    required this.htmlAttachmentTitle,
    required this.attachment,
    required this.accountId,
    required this.session,
    this.sourceView,
  });

  final String sanitizedHtmlContent;
  final String htmlAttachmentTitle;
  final Attachment attachment;
  final AccountId accountId;
  final Session session;
  final DownloadSourceView? sourceView;

  @override
  List<Object?> get props => [
        sanitizedHtmlContent,
        htmlAttachmentTitle,
        attachment,
        accountId,
        session,
        sourceView,
      ];
}

class DownloadAndGetHtmlContentFromAttachmentFailure extends FeatureFailure {
  DownloadAndGetHtmlContentFromAttachmentFailure({
    super.exception,
    required this.blobId,
    this.sourceView,
  });

  final Id? blobId;
  final DownloadSourceView? sourceView;

  @override
  List<Object?> get props => [blobId, sourceView];
}
