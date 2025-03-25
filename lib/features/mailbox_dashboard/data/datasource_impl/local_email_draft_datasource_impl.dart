import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/local_email_draft_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/local/local_email_draft_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/local/local_email_draft_worker_queue.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/local_email_draft.dart';
import 'package:tmail_ui_user/features/offline_mode/hive_worker/hive_task.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:universal_html/html.dart' as html;

class LocalEmailDraftDataSourceImpl extends LocalEmailDraftDatasource {

  final HtmlTransform _htmlTransform;
  final LocalEmailDraftManager _localEmailDraftManager;
  final LocalEmailDraftWorkerQueue _localEmailDraftWorkerQueue;
  final ExceptionThrower _exceptionThrower;

  LocalEmailDraftDataSourceImpl(
    this._htmlTransform,
    this._localEmailDraftManager,
    this._localEmailDraftWorkerQueue,
    this._exceptionThrower,
  );

  @override
  Future<List<LocalEmailDraft>> getAllLocalEmailDraft(
    AccountId accountId,
    UserName userName
  ) {
    return Future.sync(() async {
      return await _localEmailDraftManager.getAllLocalEmailDraft(accountId, userName);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> saveLocalEmailDraft(LocalEmailDraft localEmailDraft) {
    return Future.sync(() async {
      final task = HiveTask(
        id: localEmailDraft.id,
        runnable: () async {
          return await _localEmailDraftManager.saveLocalEmailDraft(localEmailDraft);
        },
      );
      return _localEmailDraftWorkerQueue.addTask(task);
    }).catchError(_exceptionThrower.throwException);
  }
  
  @override
  Future<String> restoreEmailInlineImages(
    String htmlContent,
    TransformConfiguration transformConfiguration,
    Map<String, String> mapUrlDownloadCID) {
    return Future.sync(() async {
      return await _htmlTransform.transformToHtml(
        htmlContent: htmlContent,
        transformConfiguration: transformConfiguration,
        mapCidImageDownloadUrl: mapUrlDownloadCID);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> removeAllLocalEmailDraft(AccountId accountId, UserName userName) {
    return Future.sync(() {
      final keyWithIdentity = TupleKey(
        EmailActionType.reopenComposerBrowser.name,
        accountId.asString,
        userName.value,
      ).toString();

      html.window.sessionStorage.removeWhere((key, value) => key.startsWith(keyWithIdentity));
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> removeLocalEmailDraft(AccountId accountId, UserName userName, String composerId) {
    return Future.sync(() {
      final keyWithIdentity = TupleKey(
        EmailActionType.reopenComposerBrowser.name,
        accountId.asString,
        userName.value,
        composerId,
      ).toString();

      html.window.sessionStorage.removeWhere((key, value) => key == keyWithIdentity);
    }).catchError(_exceptionThrower.throwException);
  }
}
