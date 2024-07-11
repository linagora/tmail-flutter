import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/model.dart';
import 'package:rich_text_composer/views/commons/logger.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/export_attachment_state.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';

class ExportAttachmentInteractor {
  final EmailRepository _emailRepository;
  final AccountRepository _accountRepository;

  ExportAttachmentInteractor(
    this._emailRepository,
    this._accountRepository,
  );

  Stream<Either<Failure, Success>> execute(
      Attachment attachment,
      AccountId accountId,
      String baseDownloadUrl,
      CancelToken cancelToken
  ) async* {
    try {
      final currentAccount = await _accountRepository.getCurrentAccount();

      final downloadedResponse = await _emailRepository.exportAttachment(
        attachment,
        accountId,
        baseDownloadUrl,
        currentAccount,
        cancelToken
      );

      yield Right<Failure, Success>(ExportAttachmentSuccess(downloadedResponse));
    } catch (exception) {
      logError('ExportAttachmentInteractor::execute(): exception: $exception');
      yield Left<Failure, Success>(ExportAttachmentFailure(exception));
    }
  }
}