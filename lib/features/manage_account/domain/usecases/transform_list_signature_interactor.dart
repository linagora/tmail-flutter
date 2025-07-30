import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identity_signature.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/identity_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/transform_list_signature_state.dart';

class TransformListSignatureInteractor {
  final IdentityRepository _identityRepository;

  TransformListSignatureInteractor(this._identityRepository);

  Stream<Either<Failure, Success>> execute(List<IdentitySignature> identitySignatures) async* {
    try {
      yield Right<Failure, Success>(TransformListSignatureLoading());
      final newListIdentitySignature = await Future.wait(
        identitySignatures.map(_transformHtmlSignature),
        eagerError: true,
      );
      yield Right<Failure, Success>(TransformListSignatureSuccess(newListIdentitySignature));
    } catch (exception) {
      yield Left<Failure, Success>(TransformListSignatureFailure(exception, identitySignatures));
    }
  }

  Future<IdentitySignature> _transformHtmlSignature(IdentitySignature identitySignature) async {
    try {
      return await _identityRepository.transformHtmlSignature(identitySignature);
    } catch (e) {
      logError('TransformListSignatureInteractor::_transformHtmlSignature:Exception = $e');
      return identitySignature;
    }
  }
}