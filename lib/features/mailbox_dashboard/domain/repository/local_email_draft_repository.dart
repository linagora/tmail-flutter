import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/local_email_draft.dart';

abstract class LocalEmailDraftRepository {
  Future<void> saveLocalEmailDraft({
    required AccountId accountId,
    required UserName userName,
    required LocalEmailDraft composerCache,
  });

  Future<List<LocalEmailDraft>> getLocalEmailDraft(
    AccountId accountId,
    UserName userName);

  Future<void> removeAllLocalEmailDraft(
    AccountId accountId,
    UserName userName,
  );

  Future<void> removeLocalEmailDraft(
    AccountId accountId,
    UserName userName,
    String composerId,
  );

  Future<String> restoreEmailInlineImages(
    String htmlContent,
    TransformConfiguration transformConfiguration,
    Map<String, String> mapUrlDownloadCID);
}
