import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/create_email_request_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/web_composer_reload_cache_handler.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/composer_session_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/composer_cache_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/composer_reload_cache_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_reload_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_all_composer_cache_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_composer_cache_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_composer_reload_cache_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/cache_exception_thrower.dart';
import 'package:universal_html/html.dart' as html;

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';

class _RecordingReloadRepository implements ComposerReloadCacheRepository {
  int writes = 0;
  bool failWrite = false;

  @override
  void saveSync(Session session, AccountId accountId, ComposerCache cache) {
    if (failWrite) throw StateError('storage unavailable');
    writes++;
  }
}

ComposerCache _buildCache(
  Session session,
  AccountId accountId,
  String composerId,
  String content,
) {
  final request = CreateEmailRequest(
    session: session,
    accountId: accountId,
    emailActionType: EmailActionType.compose,
    ownEmailAddress: 'alice@example.com',
    subject: 'Reload subject',
    emailContent: content,
    composerId: composerId,
  );
  return request.generateComposerCache(
    emailCreated: request.generateEmail(
      newEmailContent: content,
      newEmailAttachments: {},
      userAgent: '',
      partId: PartId('reload-body'),
      isDraft: true,
    ),
  );
}

Future<ComposerArguments> _restore(
  ComposerSessionCacheDatasourceImpl datasource,
  Session session,
  AccountId accountId,
  String composerId,
) async {
  final result = await GetAllComposerCacheInteractor(
    ComposerCacheRepositoryImpl(datasource),
  ).execute(accountId, session.username).last;
  final cache =
      (result.getOrElse(() => throw StateError('no cache'))
              as GetAllComposerCacheSuccess)
          .listComposerCache
          .singleWhere((item) => item.composerId == composerId);
  return ComposerArguments.fromSessionStorageBrowser(cache);
}

void main() {
  late _RecordingReloadRepository repository;
  late SaveComposerReloadCacheInteractor interactor;

  setUp(() {
    repository = _RecordingReloadRepository();
    interactor = SaveComposerReloadCacheInteractor(repository);
  });

  test('does not write when the snapshot is unavailable', () {
    WebComposerReloadCacheHandler(() => null, interactor).saveBeforeUnload();

    expect(repository.writes, 0);
  });

  test('does not throw if the snapshot cannot be built', () {
    final handler = WebComposerReloadCacheHandler(
      () => throw StateError('editor unavailable'),
      interactor,
    );

    expect(handler.saveBeforeUnload, returnsNormally);
    expect(repository.writes, 0);
  });

  test('does not throw if browser storage rejects the write', () {
    repository.failWrite = true;
    final handler = WebComposerReloadCacheHandler(
      () => (
        session: SessionFixtures.aliceSession,
        accountId: AccountFixtures.aliceAccountId,
        cache: ComposerCache(composerId: 'reload-composer'),
      ),
      interactor,
    );

    expect(handler.saveBeforeUnload, returnsNormally);
    expect(repository.writes, 0);
  });

  test('commits to sessionStorage before returning and restores it', () async {
    const composerId = 'browser-storage-test';
    const content = '<p>recover in this tab</p>';
    final session = SessionFixtures.aliceSession;
    final accountId = AccountFixtures.aliceAccountId;
    final cache = _buildCache(session, accountId, composerId, content);
    final datasource = ComposerSessionCacheDatasourceImpl(
      CacheExceptionThrower(),
    );
    addTearDown(
      () async => datasource.removeComposerCacheById(
        accountId,
        session.username,
        composerId,
      ),
    );
    final handler = WebComposerReloadCacheHandler(
      () => (session: session, accountId: accountId, cache: cache),
      SaveComposerReloadCacheInteractor(
        ComposerReloadCacheRepositoryImpl(datasource),
      ),
    );

    handler.saveBeforeUnload();
    final cacheKey = TupleKey(
      EmailActionType.reopenComposerBrowser.name,
      accountId.asString,
      session.username.value,
      composerId,
    ).toString();
    expect(html.window.sessionStorage[cacheKey], contains(content));

    final restored = await _restore(datasource, session, accountId, composerId);
    expect(restored.emailContents, content);
    expect(restored.presentationEmail?.subject, 'Reload subject');
  });
}
