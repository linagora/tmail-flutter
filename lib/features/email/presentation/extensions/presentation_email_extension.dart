
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_email_header_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/smime_signature_status.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/smime_signature_constant.dart';

extension PresentationEmailExtension on PresentationEmail {

  SMimeSignatureStatus get sMimeStatus {
    final status = emailHeader?.toSet().sMimeStatus;
    if (status == SMimeSignatureConstant.GOOD_SIGNATURE) {
      return SMimeSignatureStatus.goodSignature;
    } else  if (status == SMimeSignatureConstant.BAD_SIGNATURE) {
      return SMimeSignatureStatus.badSignature;
    } else {
      return SMimeSignatureStatus.notSigned;
    }
  }
}