import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/identity_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/transform_html_signature_state.dart';

class TransformHtmlSignatureInteractor {
  final IdentityRepository _identityRepository;

  TransformHtmlSignatureInteractor(this._identityRepository);

  Stream<Either<Failure, Success>> execute(String signature) async* {
    try {
      yield Right<Failure, Success>(TransformHtmlSignatureLoading());
      final signatureUnescape = await _identityRepository.transformHtmlSignature(signature);
      yield Right<Failure, Success>(TransformHtmlSignatureSuccess(signatureUnescape));
    } catch (exception) {
      yield Left<Failure, Success>(EditIdentityFailure(exception));
    }
  }
}