import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/data/constants/constant.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/upload_exception.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/oidc_fixtures.dart';
import 'file_uploader_retry_test.mocks.dart';
import 'scripted_read_file.dart';

/// Proves `FileUploader.uploadAttachment` end-to-end through a real 401 →
/// refresh → replay: the interceptor test builds `extra` by hand, and
/// `file_uploader_test.dart` calls the captured factory manually, so neither
/// one proves `FileUploader`'s own `openRead` factory survives a real replay.
@GenerateMocks([
  AuthenticationClientBase,
  TokenOidcCacheManager,
  AccountCacheManager,
  IOSSharingManager,
])
void main() {
  late AuthenticationClientBase authenticationClient;
  late TokenOidcCacheManager tokenOidcCacheManager;
  late AccountCacheManager accountCacheManager;
  late IOSSharingManager iosSharingManager;

  setUp(() {
    PlatformInfo.isTestingForWeb = false;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    dotenv.testLoad(mergeWith: {'PLATFORM': 'other'});
    authenticationClient = MockAuthenticationClientBase();
    tokenOidcCacheManager = MockTokenOidcCacheManager();
    accountCacheManager = MockAccountCacheManager();
    iosSharingManager = MockIOSSharingManager();
  });

  tearDown(() {
    PlatformInfo.isTestingForWeb = false;
    debugDefaultTargetPlatformOverride = null;
  });

  /// Rejects every request with the old token, accepts only the refreshed
  /// bearer — so the server itself proves the retry carried the new token.
  Future<HttpServer> startTokenGatedUploadServer(
    List<List<int>> receivedBodies,
    List<String?> authHeaders,
  ) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final body = <int>[];
      await for (final chunk in request) {
        body.addAll(chunk);
      }
      receivedBodies.add(body);
      final authorization = request.headers.value(HttpHeaders.authorizationHeader);
      authHeaders.add(authorization);
      request.response.statusCode = authorization == 'Bearer ${OIDCFixtures.newTokenOidc.token}'
          ? HttpStatus.ok
          : HttpStatus.unauthorized;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'accountId': 'account-id',
        'blobId': 'blob-id',
        'type': 'application/pdf',
        'size': body.length,
      }));
      await request.response.close();
    });
    addTearDown(() async {
      await server.close(force: true);
    });
    return server;
  }

  Dio buildUploadDio() {
    final dio = Dio(BaseOptions(headers: <String, dynamic>{
      HttpHeaders.acceptHeader: DioClient.jmapHeader,
      HttpHeaders.contentTypeHeader: Constant.contentTypeHeaderDefault,
    }));
    final interceptor = AuthorizationInterceptors(
      dio,
      authenticationClient,
      tokenOidcCacheManager,
      accountCacheManager,
      iosSharingManager,
    );
    interceptor.setTokenAndAuthorityOidc(
      newToken: OIDCFixtures.tokenOidcNotExpiredYet,
      newConfig: OIDCFixtures.oidcConfiguration,
    );
    dio.interceptors.add(interceptor);

    when(authenticationClient.refreshingTokensOIDC(
      OIDCFixtures.oidcConfiguration.clientId,
      OIDCFixtures.oidcConfiguration.redirectUrl,
      OIDCFixtures.oidcConfiguration.discoveryUrl,
      OIDCFixtures.oidcConfiguration.scopes,
      OIDCFixtures.tokenOidcNotExpiredYet,
    )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
    when(accountCacheManager.getCurrentAccount())
        .thenAnswer((_) async => AccountFixtures.aliceAccount);
    when(tokenOidcCacheManager.persistOneTokenOidc(OIDCFixtures.newTokenOidc))
        .thenAnswer((_) async {});
    final refreshedAccount = PersonalAccount(
      OIDCFixtures.newTokenOidc.tokenIdHash,
      AuthenticationType.oidc,
      isSelected: true,
      accountId: AccountFixtures.aliceAccountId,
      apiUrl: AccountFixtures.aliceAccount.apiUrl,
      userName: AccountFixtures.aliceAccount.userName,
    );
    when(accountCacheManager.setCurrentAccount(refreshedAccount))
        .thenAnswer((_) async {});

    return dio;
  }

  void expectRefreshedExactlyOnce() {
    verify(authenticationClient.refreshingTokensOIDC(
      OIDCFixtures.oidcConfiguration.clientId,
      OIDCFixtures.oidcConfiguration.redirectUrl,
      OIDCFixtures.oidcConfiguration.discoveryUrl,
      OIDCFixtures.oidcConfiguration.scopes,
      OIDCFixtures.tokenOidcNotExpiredYet,
    )).called(1);
  }

  test('replays a stream-backed attachment by reopening its source after 401', () async {
    final receivedBodies = <List<int>>[];
    final authHeaders = <String?>[];
    final server = await startTokenGatedUploadServer(receivedBodies, authHeaders);
    final uploadUri = Uri.parse('http://${server.address.address}:${server.port}/upload/account-id');
    var openReadCalls = 0;
    final sourceBytes = List<int>.generate(4096, (index) => index % 256);

    const scriptedPath = '/scripted/a.pdf';
    final fileInfo = FilePathInfo(
      fileName: 'a.pdf',
      fileSize: sourceBytes.length,
      filePath: scriptedPath,
      type: 'application/pdf',
    );

    final attachment = await withScriptedFiles({
      scriptedPath: ([start, end]) {
        openReadCalls++;
        return Stream<List<int>>.fromIterable([sourceBytes]);
      },
    }, () => FileUploader(DioClient(buildUploadDio()), FileUtils())
        .uploadAttachment(const UploadTaskId('upload-401-stream'), fileInfo, uploadUri)
        .timeout(const Duration(seconds: 30)));

    expect(attachment.name, 'a.pdf');
    // Once for the rejected attempt, once for the replay — a reused drained
    // stream would throw "already listened to" instead of reaching here.
    expect(openReadCalls, 2);
    expect(receivedBodies, [sourceBytes, sourceBytes]);
    expect(authHeaders, [
      'Bearer ${OIDCFixtures.tokenOidcNotExpiredYet.token}',
      'Bearer ${OIDCFixtures.newTokenOidc.token}',
    ]);
    expectRefreshedExactlyOnce();
  });

  test('rereads a file-backed attachment from disk when replaying it after 401', () async {
    final sourceBytes = List<int>.generate(4096, (index) => index % 256);
    final directory = await Directory.systemTemp.createTemp('upload-401-');
    addTearDown(() async {
      await directory.delete(recursive: true);
    });
    final file = File('${directory.path}/a.pdf');
    await file.writeAsBytes(sourceBytes);

    final receivedBodies = <List<int>>[];
    final authHeaders = <String?>[];
    final server = await startTokenGatedUploadServer(receivedBodies, authHeaders);
    final uploadUri = Uri.parse('http://${server.address.address}:${server.port}/upload/account-id');

    final fileInfo = FilePathInfo(
      fileName: 'a.pdf',
      fileSize: sourceBytes.length,
      filePath: file.path,
      type: 'application/pdf',
    );

    final attachment = await FileUploader(DioClient(buildUploadDio()), FileUtils())
        .uploadAttachment(const UploadTaskId('upload-401-file'), fileInfo, uploadUri)
        .timeout(const Duration(seconds: 30));

    expect(attachment.name, 'a.pdf');
    expect(receivedBodies, [sourceBytes, sourceBytes]);
    expectRefreshedExactlyOnce();
  });

  test('replays a bytes-backed attachment after 401', () async {
    final sourceBytes = Uint8List.fromList(<int>[9, 8, 7]);
    final receivedBodies = <List<int>>[];
    final authHeaders = <String?>[];
    final server = await startTokenGatedUploadServer(receivedBodies, authHeaders);
    final uploadUri = Uri.parse('http://${server.address.address}:${server.port}/upload/account-id');

    // The regression the openRead factory exists for: a single stored
    // BodyBytesStream would fail the replay with "already listened to".
    final fileInfo = FileBytesInfo(
      fileName: 'a.pdf',
      fileSize: sourceBytes.length,
      bytes: sourceBytes,
      type: 'application/pdf',
    );

    final attachment = await FileUploader(DioClient(buildUploadDio()), FileUtils())
        .uploadAttachment(const UploadTaskId('upload-401-bytes'), fileInfo, uploadUri)
        .timeout(const Duration(seconds: 30));

    expect(attachment.name, 'a.pdf');
    expect(receivedBodies, [sourceBytes, sourceBytes]);
    expectRefreshedExactlyOnce();
  });

  test('fails plainly when the attachment source is gone by replay time', () async {
    final receivedBodies = <List<int>>[];
    final authHeaders = <String?>[];
    final server = await startTokenGatedUploadServer(receivedBodies, authHeaders);
    final uploadUri = Uri.parse('http://${server.address.address}:${server.port}/upload/account-id');
    final sourceBytes = List<int>.generate(1024, (index) => index % 256);
    var openReadCalls = 0;

    const scriptedPath = '/scripted/a.pdf';
    final fileInfo = FilePathInfo(
      fileName: 'a.pdf',
      fileSize: sourceBytes.length,
      filePath: scriptedPath,
      type: 'application/pdf',
    );

    await withScriptedFiles({
      scriptedPath: ([start, end]) {
        openReadCalls++;
        if (openReadCalls == 2) {
          throw const FileSystemException('source gone before replay');
        }
        return Stream<List<int>>.fromIterable([sourceBytes]);
      },
    }, () => expectLater(
      FileUploader(DioClient(buildUploadDio()), FileUtils())
          .uploadAttachment(const UploadTaskId('upload-401-gone'), fileInfo, uploadUri)
          .timeout(const Duration(seconds: 30)),
      throwsA(
        isA<DioException>().having(
          (exception) => exception.error,
          'error',
          isA<MissingAttachmentSourceException>(),
        ),
      ),
    ));

    // No empty replay reached the server — it failed before a body was sent.
    expect(receivedBodies.length, 1);
    // Replay was actually attempted: one open for the original request, one
    // for the 401 retry that then threw.
    expect(openReadCalls, 2);
    expectRefreshedExactlyOnce();
  });
}
