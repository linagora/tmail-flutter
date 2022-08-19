
import 'package:forward/forward/tmail_forward.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/recipient_forward.dart';

extension TMailForwardExtension on TMailForward {

  List<RecipientForward> get listRecipientForward {
    return forwards
        .map((emailAddress) => RecipientForward(emailAddress))
        .toList();
  }
}