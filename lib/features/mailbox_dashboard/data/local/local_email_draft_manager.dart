
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/clients/local_email_draft_client.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/local_email_draft.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/local_email_draft_exception.dart';

class LocalEmailDraftManager {

  final LocalEmailDraftClient _localEmailDraftClient;

  LocalEmailDraftManager(this._localEmailDraftClient);

  Future<List<LocalEmailDraft>> getAllLocalEmailDraft(AccountId accountId, UserName userName) async {
    final nestedKey = TupleKey(accountId.asString, userName.value).encodeKey;
    final listLocalEmailDraft = await _localEmailDraftClient.getListByNestedKey(nestedKey);

    if (listLocalEmailDraft.isEmpty) {
      throw NotFoundLocalEmailDraftException();
    }

    return listLocalEmailDraft;
  }

  Future<void> saveLocalEmailDraft(LocalEmailDraft localEmailDraft) async {
    await _localEmailDraftClient.insertItem(
      localEmailDraft.id,
      localEmailDraft,
    );
  }
}