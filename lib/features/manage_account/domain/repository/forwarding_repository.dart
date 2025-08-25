import 'package:forward/forward/tmail_forward.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/add_recipients_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_recipient_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_local_copy_in_forwarding_request.dart';

abstract class ForwardingRepository {
  Future<TMailForward> getForward(AccountId accountId);

  Future<(TMailForward, SetMethodException?)> deleteRecipientInForwarding(
    AccountId accountId,
    DeleteRecipientInForwardingRequest deleteRequest,
  );

  Future<(TMailForward, SetMethodException?)> addRecipientsInForwarding(
    AccountId accountId,
    AddRecipientInForwardingRequest addRequest,
  );

  Future<(TMailForward, SetMethodException?)> editLocalCopyInForwarding(
    AccountId accountId,
    EditLocalCopyInForwardingRequest editRequest,
  );
}