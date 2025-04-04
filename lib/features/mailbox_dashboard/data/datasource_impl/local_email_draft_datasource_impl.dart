import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/local_email_draft_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/local/local_email_draft_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/local/local_email_draft_worker_queue.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/local_email_draft.dart';
import 'package:tmail_ui_user/features/offline_mode/hive_worker/hive_task.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

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
  Future<void> removeAllLocalEmailDrafts(AccountId accountId, UserName userName) {
    return Future.sync(() async {
      return await _localEmailDraftManager.removeAllLocalEmailDrafts(accountId, userName);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> removeLocalEmailDraft(String draftLocalId) {
    return Future.sync(() async {
      final task = HiveTask(
        id: draftLocalId,
        runnable: () async {
          return await _localEmailDraftManager.removeLocalEmailDraft(draftLocalId);
        },
      );
      return _localEmailDraftWorkerQueue.addTask(task);
    }).catchError(_exceptionThrower.throwException);
  }
}
