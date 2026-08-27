import 'dart:convert';
import 'dart:io';

import 'package:core/data/constants/constant.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:mockito/mockito.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

import '../../fixtures/account_fixtures.dart';
import '../../fixtures/oidc_fixtures.dart';
import 'authorization_interceptor_test.mocks.dart';

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

  Future<HttpServer> startUploadServer(
    List<List<int>> receivedBodies,
    List<String?> authorizationHeaders,
  ) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final body = <int>[];
      await for (final chunk in request) {
        body.addAll(chunk);
      }
      receivedBodies.add(body);
      final authorization = request.headers.value(HttpHeaders.authorizationHeader);
      authorizationHeaders.add(authorization);
      request.response.statusCode = authorization == 'Bearer ${OIDCFixtures.newTokenOidc.token}'
          ? HttpStatus.ok
          : HttpStatus.unauthorized;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'uploaded': true}));
      await request.response.close();
    });
    addTearDown(() async {
      await server.close(force: true);
    });
    return server;
  }

  Future<HttpServer> startAlwaysUnauthorizedServer(List<List<int>> receivedBodies) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final body = <int>[];
      await for (final chunk in request) {
        body.addAll(chunk);
      }
      receivedBodies.add(body);
      request.response.statusCode = HttpStatus.unauthorized;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'error': 'unauthorized'}));
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
      OIDCFixtures.tokenOidcNotExpiredYet.refreshToken,
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

  Options uploadOptions(List<int> sourceBytes) => Options(
    extra: <String, dynamic>{
      FileUploader.uploadAttachmentExtraKey: <String, dynamic>{
        FileUploader.streamDataExtraKey:
            BodyBytesStream.fromBytes(Uint8List.fromList(sourceBytes)),
      },
    },
  );

  Options filePathUploadOptions(String filePath, int fileSize) => Options(
    headers: <String, dynamic>{
      HttpHeaders.contentLengthHeader: fileSize,
    },
    extra: <String, dynamic>{
      FileUploader.uploadAttachmentExtraKey: <String, dynamic>{
        FileUploader.filePathExtraKey: filePath,
      },
    },
  );

  Future<File> createTempUploadFile(List<int> sourceBytes) async {
    final directory = await Directory.systemTemp.createTemp('upload-retry-');
    addTearDown(() async {
      await directory.delete(recursive: true);
    });
    final file = File('${directory.path}/attachment.pdf');
    await file.writeAsBytes(sourceBytes);
    return file;
  }

  Map<String, int> bodyDeliveryCounts(List<List<int>> receivedBodies) {
    final counts = <String, int>{};
    for (final body in receivedBodies) {
      final key = base64Encode(body);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  void expectRefreshedExactlyOnce() {
    verify(authenticationClient.refreshingTokensOIDC(
      OIDCFixtures.oidcConfiguration.clientId,
      OIDCFixtures.oidcConfiguration.redirectUrl,
      OIDCFixtures.oidcConfiguration.discoveryUrl,
      OIDCFixtures.oidcConfiguration.scopes,
      OIDCFixtures.tokenOidcNotExpiredYet.refreshToken,
    )).called(1);
  }

  /// Every upload reached the server twice with an identical body, and the
  /// replays carried the refreshed bearer token.
  void expectReplayedWithRefreshedToken({
    required List<List<int>> receivedBodies,
    required List<String?> authorizationHeaders,
    required Map<String, int> expectedBodyCounts,
    required int expectedReplays,
  }) {
    expect(bodyDeliveryCounts(receivedBodies), expectedBodyCounts);
    expect(
      authorizationHeaders
          .where((header) => header == 'Bearer ${OIDCFixtures.newTokenOidc.token}')
          .length,
      expectedReplays,
    );
  }

  test('replays concurrent attachment uploads on mobile after one shared token refresh', () async {
    final receivedBodies = <List<int>>[];
    final authorizationHeaders = <String?>[];
    final server = await startUploadServer(receivedBodies, authorizationHeaders);
    final dio = buildUploadDio();
    final sourceA = <int>[1, 2, 3];
    final sourceB = <int>[4, 5, 6];
    final uploadUrl = 'http://${server.address.address}:${server.port}/upload/account-id';

    final responses = await Future.wait([
      dio.post(
        uploadUrl,
        data: Stream<List<int>>.value(sourceA),
        options: uploadOptions(sourceA),
      ),
      dio.post(
        uploadUrl,
        data: Stream<List<int>>.value(sourceB),
        options: uploadOptions(sourceB),
      ),
    ]).timeout(const Duration(seconds: 30));

    expect(responses.map((response) => response.statusCode), [HttpStatus.ok, HttpStatus.ok]);
    expectReplayedWithRefreshedToken(
      receivedBodies: receivedBodies,
      authorizationHeaders: authorizationHeaders,
      expectedBodyCounts: {
        base64Encode(sourceA): 2,
        base64Encode(sourceB): 2,
      },
      expectedReplays: 2,
    );
    expectRefreshedExactlyOnce();
  });

  test('rereads a file-path attachment from disk when replaying it on mobile after 401', () async {
    final sourceBytes = List<int>.generate(4096, (index) => index % 256);
    final file = await createTempUploadFile(sourceBytes);
    final receivedBodies = <List<int>>[];
    final authorizationHeaders = <String?>[];
    final server = await startUploadServer(receivedBodies, authorizationHeaders);
    final dio = buildUploadDio();

    final response = await dio.post(
      'http://${server.address.address}:${server.port}/upload/account-id',
      data: file.openRead(),
      options: filePathUploadOptions(file.path, sourceBytes.length),
    ).timeout(const Duration(seconds: 30));

    expect(response.statusCode, HttpStatus.ok);
    expectReplayedWithRefreshedToken(
      receivedBodies: receivedBodies,
      authorizationHeaders: authorizationHeaders,
      expectedBodyCounts: {base64Encode(sourceBytes): 2},
      expectedReplays: 1,
    );
  });

  test('keeps reporting upload progress on the mobile replay after 401', () async {
    final sourceBytes = List<int>.generate(4096, (index) => index % 256);
    final file = await createTempUploadFile(sourceBytes);
    final receivedBodies = <List<int>>[];
    final authorizationHeaders = <String?>[];
    final server = await startUploadServer(receivedBodies, authorizationHeaders);
    final dio = buildUploadDio();
    final completedProgressEvents = <int>[];

    final response = await dio.post(
      'http://${server.address.address}:${server.port}/upload/account-id',
      data: file.openRead(),
      options: filePathUploadOptions(file.path, sourceBytes.length),
      onSendProgress: (count, total) {
        if (count == total) {
          completedProgressEvents.add(count);
        }
      },
    ).timeout(const Duration(seconds: 30));

    expect(response.statusCode, HttpStatus.ok);
    expect(receivedBodies.length, 2);
    // The replay must keep the original `onSendProgress`, otherwise the
    // attachment chip freezes at the progress reached before the 401.
    expect(completedProgressEvents, [sourceBytes.length, sourceBytes.length]);
  });

  test('replays the attachment body on web after 401 through the legacy retry path', () async {
    PlatformInfo.isTestingForWeb = true;
    final receivedBodies = <List<int>>[];
    final authorizationHeaders = <String?>[];
    final server = await startUploadServer(receivedBodies, authorizationHeaders);
    final dio = buildUploadDio();
    final sourceBytes = <int>[11, 22, 33];

    final response = await dio.post(
      'http://${server.address.address}:${server.port}/upload/account-id',
      data: Stream<List<int>>.value(sourceBytes),
      options: uploadOptions(sourceBytes),
    ).timeout(const Duration(seconds: 30));

    // Web keeps master's `retryDio.request(...)` path; it must still rebuild the
    // consumed body from streamData rather than replaying an empty request.
    expect(response.statusCode, HttpStatus.ok);
    expectReplayedWithRefreshedToken(
      receivedBodies: receivedBodies,
      authorizationHeaders: authorizationHeaders,
      expectedBodyCounts: {base64Encode(sourceBytes): 2},
      expectedReplays: 1,
    );
  });

  test('stops after one replay when the mobile upload is still rejected', () async {
    final sourceBytes = List<int>.generate(1024, (index) => index % 256);
    final file = await createTempUploadFile(sourceBytes);
    final receivedBodies = <List<int>>[];
    final server = await startAlwaysUnauthorizedServer(receivedBodies);
    final dio = buildUploadDio();

    await expectLater(
      dio.post(
        'http://${server.address.address}:${server.port}/upload/account-id',
        data: file.openRead(),
        options: filePathUploadOptions(file.path, sourceBytes.length),
      ).timeout(const Duration(seconds: 30)),
      throwsA(isA<DioException>()),
    );

    // The replay carries _refreshAttemptedKey through copyWith, so a second 401
    // must give up rather than refresh and retry forever.
    expect(receivedBodies.length, 2);
    expectRefreshedExactlyOnce();
  });

  test('fails plainly when the mobile replay body cannot be rebuilt', () async {
    final sourceBytes = <int>[1, 2, 3];
    final receivedBodies = <List<int>>[];
    final authorizationHeaders = <String?>[];
    final server = await startUploadServer(receivedBodies, authorizationHeaders);
    final dio = buildUploadDio();

    // Malformed extras: neither a path nor a stream, so the replay body is null.
    // It must not silently resend the already-consumed original stream.
    final response = await dio.post(
      'http://${server.address.address}:${server.port}/upload/account-id',
      data: Stream<List<int>>.value(sourceBytes),
      options: Options(
        extra: <String, dynamic>{
          FileUploader.uploadAttachmentExtraKey: <String, dynamic>{},
        },
      ),
    ).timeout(const Duration(seconds: 30));

    expect(response.statusCode, HttpStatus.ok);
    expect(receivedBodies, [sourceBytes, isEmpty]);
  });
}
