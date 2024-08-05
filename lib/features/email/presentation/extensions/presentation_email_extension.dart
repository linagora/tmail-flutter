
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_email_header_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/smime_signature_status.dart';

extension PresentationEmailExtension on PresentationEmail {

  SMimeSignatureStatus get sMimeStatus {
    final status = emailHeader?.toSet().sMimeStatus;
    if (status == 'Good signature') {
      return SMimeSignatureStatus.goodSignature;
    } else  if (status == 'Bad signature') {
      return SMimeSignatureStatus.badSignature;
    } else {
      return SMimeSignatureStatus.notSigned;
    }
  }
}