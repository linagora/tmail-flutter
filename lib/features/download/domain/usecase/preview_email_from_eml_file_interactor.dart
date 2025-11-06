import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/email/domain/model/preview_email_eml_request.dart';
import 'package:tmail_ui_user/features/download/domain/state/preview_email_from_eml_file_state.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/features/download/domain/repository/download_repository.dart';

class PreviewEmailFromEmlFileInteractor {
  final DownloadRepository _downloadRepository;

  const PreviewEmailFromEmlFileInteractor(this._downloadRepository);

  Stream<Either<Failure, Success>> execute(
    PreviewEmailEMLRequest previewEmailEMLRequest,
  ) async* {
    try {
      yield Right<Failure, Success>(PreviewingEmailFromEmlFile());

      final previewEMLContent = await _downloadRepository
        .generatePreviewEmailEMLContent(previewEmailEMLRequest);

      final emlPreviewer = EMLPreviewer(
        id: previewEmailEMLRequest.keyStored,
        title: previewEmailEMLRequest.title,
        content: previewEMLContent,
      );

      if (PlatformInfo.isWeb) {
        if (previewEmailEMLRequest.isShared) {
          await _downloadRepository.sharePreviewEmailEMLContent(emlPreviewer);
        } else {
          await _downloadRepository.storePreviewEMLContentToSessionStorage(
            emlPreviewer,
          );
        }
      }

      yield Right<Failure, Success>(
        PreviewEmailFromEmlFileSuccess(
          emlPreviewer,
          previewEmailEMLRequest.accountId,
          previewEmailEMLRequest.session,
          previewEmailEMLRequest.ownEmailAddress,
          previewEmailEMLRequest.appLocalizations,
        ),
      );
    } catch (e) {
      yield Left<Failure, Success>(PreviewEmailFromEmlFileFailure(e));
    }
  }
}