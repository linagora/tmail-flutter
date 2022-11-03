import 'package:forward/forward/tmail_forward.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/add_recipients_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_recipient_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_local_copy_in_forwarding_request.dart';

abstract class ForwardingDataSource {
  Future<TMailForward> getForward(AccountId accountId);

  Future<TMailForward> deleteRecipientInForwarding(AccountId accountId, DeleteRecipientInForwardingRequest deleteRequest);

  Future<TMailForward> addRecipientsInForwarding(AccountId accountId, AddRecipientInForwardingRequest addRequest);

  Future<TMailForward> editLocalCopyInForwarding(AccountId accountId, EditLocalCopyInForwardingRequest editRequest);
}