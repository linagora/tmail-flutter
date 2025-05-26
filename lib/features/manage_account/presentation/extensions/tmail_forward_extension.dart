
import 'package:forward/forward/tmail_forward.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/recipient_forward.dart';

extension TMailForwardExtension on TMailForward {

  List<RecipientForward> get listRecipientForward {
    return forwards
        ?.map((value) => RecipientForward(EmailAddress(value, value)))
        .toList() ?? [];
  }
}