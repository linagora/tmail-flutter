import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/local_email_draft.dart';

abstract class LocalEmailDraftDatasource {
  Future<void> saveLocalEmailDraft(LocalEmailDraft localEmailDraft);

  Future<List<LocalEmailDraft>> getAllLocalEmailDraft(
    AccountId accountId,
    UserName userName);

  Future<void> removeAllLocalEmailDrafts(
    AccountId accountId,
    UserName userName,
  );

  Future<void> removeLocalEmailDraft(String draftLocalId);

  Future<String> restoreEmailInlineImages(
    String htmlContent,
    TransformConfiguration transformConfiguration,
    Map<String, String> mapUrlDownloadCID);
}