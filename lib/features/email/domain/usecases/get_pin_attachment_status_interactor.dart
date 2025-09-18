import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_pin_attachment_status_state.dart';

class GetPinAttachmentStatusInteractor {
  final EmailRepository _emailRepository;

  const GetPinAttachmentStatusInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(GettingPinAttachmentStatus());
      final isEnabled = await _emailRepository.isPinAttachmentEnabled();
      yield Right<Failure, Success>(GetPinAttachmentStatusSuccess(isEnabled));
    } catch (e) {
      yield Left<Failure, Success>(GetPinAttachmentStatusFailure(e));
    }
  }
}
