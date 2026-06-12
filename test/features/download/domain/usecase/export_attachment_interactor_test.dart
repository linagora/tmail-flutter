import 'package:core/data/network/download/downloaded_response.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/download/domain/model/export_attachment_request.dart';
import 'package:tmail_ui_user/features/download/domain/repository/download_repository.dart';
import 'package:tmail_ui_user/features/download/domain/state/export_attachment_state.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/export_attachment_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/oidc_fixtures.dart';

import 'export_attachment_interactor_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<DownloadRepository>(),
  MockSpec<CredentialRepository>(),
  MockSpec<AccountRepository>(),
  MockSpec<AuthenticationOIDCRepository>(),
])
void main() {
  late MockDownloadRepository downloadRepository;
  late MockCredentialRepository credentialRepository;
  late MockAccountRepository accountRepository;
  late MockAuthenticationOIDCRepository authenticationOIDCRepository;
  late ExportAttachmentInteractor interactor;

  final oidcAccount = PersonalAccount(
    'oidc-account-id',
    AuthenticationType.oidc,
    isSelected: true,
    accountId: AccountFixtures.aliceAccountId,
  );

  final basicAccount = PersonalAccount(
    'basic-account-id',
    AuthenticationType.basic,
    isSelected: true,
    accountId: AccountFixtures.aliceAccountId,
  );

  final attachment = Attachment(blobId: Id('blob-1'));
  final cancelToken = CancelToken();
  final downloadedResponse = DownloadedResponse('/tmp/file.pdf');

  ExportAttachmentRequest buildRequest({bool withFallback = false}) =>
      ExportAttachmentRequest(
        attachment: attachment,
        accountId: AccountFixtures.aliceAccountId,
        baseDownloadUrl: 'https://example.com/{accountId}/{blobId}/{name}/{type}',
        cancelToken: cancelToken,
        fallbackToken: withFallback ? OIDCFixtures.newTokenOidc : null,
      );

  setUp(() {
    downloadRepository = MockDownloadRepository();
    credentialRepository = MockCredentialRepository();
    accountRepository = MockAccountRepository();
    authenticationOIDCRepository = MockAuthenticationOIDCRepository();
    interactor = ExportAttachmentInteractor(
      downloadRepository,
      credentialRepository,
      accountRepository,
      authenticationOIDCRepository,
    );
  });

  group('ExportAttachmentInteractor:', () {
    group('OIDC auth -', () {
      setUp(() {
        when(accountRepository.getCurrentAccount())
            .thenAnswer((_) async => oidcAccount);
        when(downloadRepository.exportAttachment(any, any, any, any, any))
            .thenAnswer((_) async => downloadedResponse);
      });

      test(
        'should use token from storage and yield success '
        'when token storage succeeds',
        () {
          when(authenticationOIDCRepository.getStoredTokenOIDC(any))
              .thenAnswer((_) async => OIDCFixtures.newTokenOidc);

          expect(
            interactor.execute(buildRequest()),
            emitsInOrder([
              Right(ExportAttachmentSuccess(downloadedResponse)),
            ]),
          );
        },
      );

      test(
        'should use fallback token, repair token storage, and yield success '
        'when token storage fails and fallbackToken is provided',
        () async {
          when(authenticationOIDCRepository.getStoredTokenOIDC(any))
              .thenThrow(Exception('storage error'));

          await expectLater(
            interactor.execute(buildRequest(withFallback: true)),
            emitsInOrder([
              Right(ExportAttachmentSuccess(downloadedResponse)),
            ]),
          );

          verify(authenticationOIDCRepository.persistTokenOIDC(OIDCFixtures.newTokenOidc)).called(1);
        },
      );

      test(
        'should still yield success '
        'when token storage repair fails',
        () async {
          when(authenticationOIDCRepository.getStoredTokenOIDC(any))
              .thenThrow(Exception('storage error'));
          when(authenticationOIDCRepository.persistTokenOIDC(any))
              .thenAnswer((_) => Future.error(Exception('persist error')));

          await expectLater(
            interactor.execute(buildRequest(withFallback: true)),
            emitsInOrder([
              Right(ExportAttachmentSuccess(downloadedResponse)),
            ]),
          );
        },
      );

      test(
        'should yield failure '
        'when token storage fails and no fallbackToken is provided',
        () {
          when(authenticationOIDCRepository.getStoredTokenOIDC(any))
              .thenThrow(Exception('storage error'));

          expect(
            interactor.execute(buildRequest()),
            emitsInOrder([
              isA<Left<Failure, Success>>()
                  .having((l) => l.value, 'failure', isA<ExportAttachmentFailure>()),
            ]),
          );
        },
      );
    });

    group('Basic auth -', () {
      setUp(() {
        when(accountRepository.getCurrentAccount())
            .thenAnswer((_) async => basicAccount);
        when(credentialRepository.getAuthenticationInfoStored())
            .thenAnswer((_) async => AuthenticationInfoCache('user@example.com', 'secret'));
        when(downloadRepository.exportAttachment(any, any, any, any, any))
            .thenAnswer((_) async => downloadedResponse);
      });

      test(
        'should use credentials from storage and yield success',
        () {
          expect(
            interactor.execute(buildRequest()),
            emitsInOrder([
              Right(ExportAttachmentSuccess(downloadedResponse)),
            ]),
          );
        },
      );
    });

    test(
      'should yield failure '
      'when download repository throws',
      () {
        when(accountRepository.getCurrentAccount())
            .thenAnswer((_) async => oidcAccount);
        when(authenticationOIDCRepository.getStoredTokenOIDC(any))
            .thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        when(downloadRepository.exportAttachment(any, any, any, any, any))
            .thenThrow(Exception('network error'));

        expect(
          interactor.execute(buildRequest()),
          emitsInOrder([
            isA<Left<Failure, Success>>()
                .having((l) => l.value, 'failure', isA<ExportAttachmentFailure>()),
          ]),
        );
      },
    );
  });
}
