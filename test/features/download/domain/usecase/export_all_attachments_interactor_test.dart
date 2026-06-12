import 'package:core/data/network/download/downloaded_response.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/download/domain/model/export_all_attachments_request.dart';
import 'package:tmail_ui_user/features/download/domain/repository/download_repository.dart';
import 'package:tmail_ui_user/features/download/domain/state/export_all_attachments_state.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/export_all_attachments_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/oidc_fixtures.dart';

import 'export_all_attachments_interactor_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<DownloadRepository>(),
  MockSpec<AccountRepository>(),
  MockSpec<AuthenticationOIDCRepository>(),
  MockSpec<CredentialRepository>(),
])
void main() {
  late MockDownloadRepository downloadRepository;
  late MockAccountRepository accountRepository;
  late MockAuthenticationOIDCRepository authenticationOIDCRepository;
  late MockCredentialRepository credentialRepository;
  late ExportAllAttachmentsInteractor interactor;

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

  final emailId = EmailId(Id('email-1'));
  final cancelToken = CancelToken();
  final downloadedResponse = DownloadedResponse('/tmp/attachments.zip');

  ExportAllAttachmentsRequest buildRequest({bool withFallback = false}) =>
      ExportAllAttachmentsRequest(
        accountId: AccountFixtures.aliceAccountId,
        emailId: emailId,
        baseDownloadAllUrl: 'https://example.com/download-all',
        outputFileName: 'attachments.zip',
        cancelToken: cancelToken,
        fallbackToken: withFallback ? OIDCFixtures.newTokenOidc : null,
      );

  setUp(() {
    downloadRepository = MockDownloadRepository();
    accountRepository = MockAccountRepository();
    authenticationOIDCRepository = MockAuthenticationOIDCRepository();
    credentialRepository = MockCredentialRepository();
    interactor = ExportAllAttachmentsInteractor(
      downloadRepository,
      accountRepository,
      authenticationOIDCRepository,
      credentialRepository,
    );
  });

  group('ExportAllAttachmentsInteractor:', () {
    group('OIDC auth -', () {
      setUp(() {
        when(accountRepository.getCurrentAccount())
            .thenAnswer((_) async => oidcAccount);
        when(downloadRepository.exportAllAttachments(any, any, any, any, any, any))
            .thenAnswer((_) async => downloadedResponse);
      });

      test(
        'should use token from storage and yield loading then success '
        'when token storage succeeds',
        () {
          when(authenticationOIDCRepository.getStoredTokenOIDC(any))
              .thenAnswer((_) async => OIDCFixtures.newTokenOidc);

          expect(
            interactor.execute(buildRequest()),
            emitsInOrder([
              Right(ExportingAllAttachments()),
              Right(ExportAllAttachmentsSuccess(downloadedResponse)),
            ]),
          );
        },
      );

      test(
        'should use fallback token and yield loading then success '
        'when token storage fails and fallbackToken is provided',
        () {
          when(authenticationOIDCRepository.getStoredTokenOIDC(any))
              .thenThrow(Exception('storage error'));

          expect(
            interactor.execute(buildRequest(withFallback: true)),
            emitsInOrder([
              Right(ExportingAllAttachments()),
              Right(ExportAllAttachmentsSuccess(downloadedResponse)),
            ]),
          );
        },
      );

      test(
        'should yield loading then failure '
        'when token storage fails and no fallbackToken is provided',
        () {
          when(authenticationOIDCRepository.getStoredTokenOIDC(any))
              .thenThrow(Exception('storage error'));

          expect(
            interactor.execute(buildRequest()),
            emitsInOrder([
              Right(ExportingAllAttachments()),
              isA<Left<Failure, Success>>()
                  .having((l) => l.value, 'failure', isA<ExportAllAttachmentsFailure>()),
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
        when(downloadRepository.exportAllAttachments(any, any, any, any, any, any))
            .thenAnswer((_) async => downloadedResponse);
      });

      test(
        'should use credentials from storage and yield loading then success',
        () {
          expect(
            interactor.execute(buildRequest()),
            emitsInOrder([
              Right(ExportingAllAttachments()),
              Right(ExportAllAttachmentsSuccess(downloadedResponse)),
            ]),
          );
        },
      );
    });

    test(
      'should yield loading then failure '
      'when download repository throws',
      () {
        when(accountRepository.getCurrentAccount())
            .thenAnswer((_) async => oidcAccount);
        when(authenticationOIDCRepository.getStoredTokenOIDC(any))
            .thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        when(downloadRepository.exportAllAttachments(any, any, any, any, any, any))
            .thenThrow(Exception('network error'));

        expect(
          interactor.execute(buildRequest()),
          emitsInOrder([
            Right(ExportingAllAttachments()),
            isA<Left<Failure, Success>>()
                .having((l) => l.value, 'failure', isA<ExportAllAttachmentsFailure>()),
          ]),
        );
      },
    );
  });
}
