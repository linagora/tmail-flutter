import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/mailbox_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_isolate_worker.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/jmap_mailbox_response.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/remote_exception_thrower.dart';

class _FakeSession implements Session {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedMailboxIsolateWorker implements MailboxIsolateWorker {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMailboxAPI implements MailboxAPI {
  _FakeMailboxAPI(this._answers);

  final List<Object> _answers;
  int getAllCalls = 0;
  int createCalls = 0;

  @override
  Future<JmapMailboxResponse> getAllMailbox(
    Session session,
    AccountId accountId, {
    properties,
  }) async {
    final answer = _answers[getAllCalls++];
    if (answer is JmapMailboxResponse) return answer;
    throw answer;
  }

  @override
  Future<Mailbox?> createNewMailbox(
    Session session,
    AccountId accountId,
    CreateNewMailboxRequest request,
  ) async {
    createCalls++;
    throw _socketError();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DioException _socketError() => DioException(
      requestOptions: RequestOptions(path: '/jmap'),
      type: DioExceptionType.unknown,
      error: const SocketException('Connection reset by peer'),
    );

void main() {
  final session = _FakeSession();
  final accountId = AccountId(Id('account'));

  MailboxDataSourceImpl dataSourceWith(MailboxAPI api) => MailboxDataSourceImpl(
        api,
        _UnusedMailboxIsolateWorker(),
        RemoteExceptionThrower(),
      );

  test(
    'WHEN Mailbox/get fails once on a socket error\n'
    'THEN it is sent again and its result is returned',
    () {
      fakeAsync((async) {
        final response = JmapMailboxResponse(mailboxes: []);
        final api = _FakeMailboxAPI([_socketError(), response]);
        JmapMailboxResponse? result;

        dataSourceWith(api)
            .getAllMailbox(session, accountId)
            .then((value) => result = value);
        async.flushTimers();

        expect(result, same(response));
        expect(api.getAllCalls, 2);
      });
    },
  );

  test(
    'WHEN creating a folder fails on a socket error\n'
    'THEN the write is not sent again',
    () {
      fakeAsync((async) {
        final api = _FakeMailboxAPI([]);
        Object? error;

        dataSourceWith(api)
            .createNewMailbox(
              session,
              accountId,
              CreateNewMailboxRequest(MailboxName('Folder')),
            )
            .catchError((Object e) {
          error = e;
          return null;
        });
        async.flushTimers();

        expect(error, isA<SocketError>());
        expect(api.createCalls, 1);
      });
    },
  );
}
