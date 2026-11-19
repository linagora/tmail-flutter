import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/method/method.dart';
import 'package:jmap_dart_client/jmap/core/method/method_response.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/home/data/network/session_api.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';
import 'package:tmail_ui_user/features/upload/data/network/blob_upload_adapter.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:uuid/uuid.dart';

import '../test_backend.dart';
import '../test_timeouts.dart';
import '../wait_for_condition.dart';

/// JMAP client for test data setup, independent of the app (no GetX, no controllers).
///
/// Talks to the backend with Basic Auth from the `--dart-define` credentials and
/// reuses the app's network API classes with its own [HttpClient].
class JmapTestClient {
  JmapTestClient._(
    this.backendUrl,
    this.session,
    this.accountId,
    this.httpClient,
    this.dioClient,
    this.apiUrl,
  );

  final String backendUrl;
  final Session session;
  final AccountId accountId;
  final HttpClient httpClient;
  final DioClient dioClient;
  final String apiUrl;

  static Future<JmapTestClient> current() async {
    final backendUrl = TestBackend.current.url;
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const password = String.fromEnvironment('PASSWORD');
    final missing = {
      'BASIC_AUTH_URL': backendUrl,
      'BASIC_AUTH_EMAIL': email,
      'PASSWORD': password,
    }.entries.where((entry) => entry.value.isEmpty).map((entry) => entry.key);
    if (missing.isNotEmpty) {
      throw StateError('JmapTestClient: missing dart-define ${missing.join(', ')}');
    }
    return _connect(backendUrl, email, password);
  }

  static Future<JmapTestClient> _connect(
    String backendUrl,
    String email,
    String password,
  ) async {
    final auth = 'Basic ${base64Encode(utf8.encode('$email:$password'))}';
    final session = await SessionAPI(HttpClient(_newDio(backendUrl, auth)))
        .getSession(converters: SessionExtensions.customMapCapabilitiesConverter);
    final apiUrl = session.getQualifiedApiUrl(baseUrl: backendUrl);
    final apiDio = _newDio(apiUrl, auth);
    return JmapTestClient._(
      backendUrl,
      session,
      session.personalAccount.accountId,
      HttpClient(apiDio),
      DioClient(apiDio),
      apiUrl,
    );
  }

  static Dio _newDio(String baseUrl, String auth) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'authorization': auth,
          'accept': HttpClient.jmapHeader,
        },
        connectTimeout: TestTimeouts.long,
        receiveTimeout: TestTimeouts.long,
        sendTimeout: TestTimeouts.long,
      ),
    );
    // Same web upload path as the app, so Blob-backed files are not sent empty.
    installBlobUploadAdapter(dio);
    return dio;
  }

  /// Upload URLs resolve against the server root, like the app's `DynamicUrlInterceptors.jmapUrl`.
  Uri get uploadUri => session.getUploadUri(accountId, jmapUrl: backendUrl);

  /// Waits for the app to create missing default folders, as the dashboard did before.
  Future<MailboxId> mailboxIdByRole(Role role) async {
    MailboxId? id;
    await waitForCondition(
      () async => (id = await _findMailboxId((m) => m.role == role)) != null,
      timeout: TestTimeouts.long,
      reason: 'No mailbox with role ${role.value}',
    );
    return id!;
  }

  /// The app also treats a role-less top-level mailbox named "Outbox" as the outbox.
  Future<MailboxId?> outboxMailboxId() => _findMailboxId(
        (m) =>
            m.role == PresentationMailbox.roleOutbox ||
            (m.parentId == null &&
                m.name?.name.toLowerCase() == PresentationMailbox.outboxRole),
      );

  Future<MailboxId?> _findMailboxId(bool Function(Mailbox) test) async {
    final response =
        await MailboxAPI(httpClient, const Uuid()).getAllMailbox(session, accountId);
    return response.mailboxes.firstWhereOrNull(test)?.id;
  }

  Future<T> execute<T extends MethodResponse>(
    Method method,
    T Function(Map<String, dynamic>) deserialize,
  ) async {
    final builder = JmapRequestBuilder(httpClient, ProcessingInvocation());
    final invocation = builder.invocation(method);
    final response = await (builder
          ..usings(method.requiredCapabilities
              .toCapabilitiesSupportTeamMailboxes(session, accountId)))
        .build()
        .execute();
    return response.parse<T>(invocation.methodCallId, deserialize) ??
        (throw StateError('JmapTestClient: no ${method.methodName} response'));
  }
}
