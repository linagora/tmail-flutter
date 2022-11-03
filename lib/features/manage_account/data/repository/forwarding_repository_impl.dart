import 'package:forward/forward/tmail_forward.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/forwarding_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/add_recipients_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_recipient_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_local_copy_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/forwarding_repository.dart';

class ForwardingRepositoryImpl extends ForwardingRepository {
  final ForwardingDataSource dataSource;

  ForwardingRepositoryImpl(this.dataSource);

  @override
  Future<TMailForward> addRecipientsInForwarding(AccountId accountId, AddRecipientInForwardingRequest addRequest) {
    return dataSource.addRecipientsInForwarding(accountId, addRequest);
  }

  @override
  Future<TMailForward> deleteRecipientInForwarding(AccountId accountId, DeleteRecipientInForwardingRequest deleteRequest) {
    return dataSource.deleteRecipientInForwarding(accountId, deleteRequest);
  }

  @override
  Future<TMailForward> editLocalCopyInForwarding(AccountId accountId, EditLocalCopyInForwardingRequest editRequest) {
    return dataSource.editLocalCopyInForwarding(accountId, editRequest);
  }

  @override
  Future<TMailForward> getForward(AccountId accountId) {
    return dataSource.getForward(accountId);
  }
}