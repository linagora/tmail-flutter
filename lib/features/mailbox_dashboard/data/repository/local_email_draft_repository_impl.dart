import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/local_email_draft_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/local_email_draft.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/local_email_draft_repository.dart';

class LocalEmailDraftRepositoryImpl extends LocalEmailDraftRepository {

  final LocalEmailDraftDatasource _localEmailDraftDatasource;

  LocalEmailDraftRepositoryImpl(this._localEmailDraftDatasource);

  @override
  Future<List<LocalEmailDraft>> getLocalEmailDraft(
    AccountId accountId,
    UserName userName
  ) {
    return _localEmailDraftDatasource.getLocalEmailDraft(accountId, userName);
  }

  @override
  Future<void> removeAllLocalEmailDraft(AccountId accountId, UserName userName) {
    return _localEmailDraftDatasource.removeAllLocalEmailDraft(accountId, userName);
  }

  @override
  Future<void> removeLocalEmailDraft(AccountId accountId, UserName userName, String composerId) {
    return _localEmailDraftDatasource.removeLocalEmailDraft(accountId, userName, composerId);
  }

  @override
  Future<void> saveLocalEmailDraft({
    required AccountId accountId,
    required UserName userName,
    required LocalEmailDraft composerCache,
  }) {
    return _localEmailDraftDatasource.saveLocalEmailDraft(
      accountId: accountId,
      userName: userName,
      composerCache: composerCache);
  }

  @override
  Future<String> restoreEmailInlineImages(
    String htmlContent,
    TransformConfiguration transformConfiguration,
    Map<String, String> mapUrlDownloadCID) {
    return _localEmailDraftDatasource.restoreEmailInlineImages(
      htmlContent,
      transformConfiguration,
      mapUrlDownloadCID);
  }
}