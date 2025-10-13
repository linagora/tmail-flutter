import 'package:forward/forward/tmail_forward.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/forwarding_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/forwarding_api.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/add_recipients_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_recipient_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_local_copy_in_forwarding_request.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class ForwardingDataSourceImpl extends ForwardingDataSource {

  final ForwardingAPI _forwardingAPI;
  final ExceptionThrower _exceptionThrower;

  ForwardingDataSourceImpl(this._forwardingAPI, this._exceptionThrower);

  @override
  Future<TMailForward> getForward(AccountId accountId) {
    return Future.sync(() async {
      return await _forwardingAPI.getForward(accountId);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<(TMailForward, SetMethodException?)> deleteRecipientInForwarding(
    AccountId accountId,
    DeleteRecipientInForwardingRequest deleteRequest,
  ) {
    return Future.sync(() async {
      return await _forwardingAPI.updateForward(
        accountId,
        deleteRequest.newTMailForward,
      );
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<(TMailForward, SetMethodException?)> addRecipientsInForwarding(
    AccountId accountId,
    AddRecipientInForwardingRequest addRequest,
  ) {
    return Future.sync(() async {
      return await _forwardingAPI.updateForward(
        accountId,
        addRequest.newTMailForward,
      );
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<(TMailForward, SetMethodException?)> editLocalCopyInForwarding(
    AccountId accountId,
    EditLocalCopyInForwardingRequest editRequest,
  ) {
    return Future.sync(() async {
      return await _forwardingAPI.updateForward(
        accountId,
        editRequest.newTMailForward,
      );
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }
}