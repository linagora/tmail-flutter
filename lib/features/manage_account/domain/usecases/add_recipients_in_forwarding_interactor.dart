import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/add_recipients_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/forwarding_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/add_recipient_in_forwarding_state.dart';

class AddRecipientsInForwardingInteractor {
  final ForwardingRepository _forwardingRepository;

  AddRecipientsInForwardingInteractor(this._forwardingRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    AddRecipientInForwardingRequest addRequest,
  ) async* {
    try {
      yield Right<Failure, Success>(LoadingState());
      final result = await _forwardingRepository.addRecipientsInForwarding(accountId, addRequest);
      yield Right<Failure, Success>(AddRecipientsInForwardingSuccess(result));
    } catch (exception) {
      yield Left<Failure, Success>(AddRecipientsInForwardingFailure(exception));
    }
  }
}
