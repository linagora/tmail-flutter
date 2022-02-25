import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_change_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';

class MailboxDataSourceImpl extends MailboxDataSource {

  final MailboxAPI mailboxAPI;

  MailboxDataSourceImpl(this.mailboxAPI);

  @override
  Future<MailboxResponse> getAllMailbox(AccountId accountId, {Properties? properties}) {
    return Future.sync(() async {
      return await mailboxAPI.getAllMailbox(accountId, properties: properties);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<MailboxChangeResponse> getChanges(AccountId accountId, State sinceState) {
    return Future.sync(() async {
      return await mailboxAPI.getChanges(accountId, sinceState);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> update({List<Mailbox>? updated, List<Mailbox>? created, List<MailboxId>? destroyed}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Mailbox>> getAllMailboxCache() {
    throw UnimplementedError();
  }

  @override
  Future<Mailbox?> createNewMailbox(AccountId accountId, CreateNewMailboxRequest newMailboxRequest) {
    return Future.sync(() async {
      return await mailboxAPI.createNewMailbox(accountId, newMailboxRequest);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<bool> deleteMultipleMailbox(AccountId accountId, List<MailboxId> mailboxIds) {
    return Future.sync(() async {
      return await mailboxAPI.deleteMultipleMailbox(accountId, mailboxIds);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<bool> renameMailbox(AccountId accountId, RenameMailboxRequest request) {
    return Future.sync(() async {
      return await mailboxAPI.renameMailbox(accountId, request);
    }).catchError((error) {
      throw error;
    });
  }
}