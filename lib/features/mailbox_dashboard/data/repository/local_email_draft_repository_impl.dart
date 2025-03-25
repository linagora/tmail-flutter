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
  Future<List<LocalEmailDraft>> getAllLocalEmailDraft(
    AccountId accountId,
    UserName userName
  ) {
    return _localEmailDraftDatasource.getAllLocalEmailDraft(accountId, userName);
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
  Future<void> saveLocalEmailDraft(LocalEmailDraft localEmailDraft) {
    return _localEmailDraftDatasource.saveLocalEmailDraft(localEmailDraft);
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