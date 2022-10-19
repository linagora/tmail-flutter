import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/email/domain/model/send_receipt_to_sender_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/mdn_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/send_receipt_to_sender_state.dart';

class SendReceiptToSenderInteractor {
  final MdnRepository _mdnRepository;

  SendReceiptToSenderInteractor(this._mdnRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, SendReceiptToSenderRequest request) async* {
    try {
      yield Right<Failure, Success>(SendReceiptToSenderLoading());
      final mdn = await _mdnRepository.sendReceiptToSender(accountId, request);
      if (mdn != null) {
        yield Right<Failure, Success>(SendReceiptToSenderSuccess(mdn));
      } else {
        yield Left<Failure, Success>(SendReceiptToSenderFailure(null));
      }
    } catch (e) {
      yield Left<Failure, Success>(SendReceiptToSenderFailure(e));
    }
  }
}