import 'package:delegation/model/delegated_account.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/delegation/data/datasource_impl/delegated_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/delegation/data/network/delegated_account_api.dart';
import 'package:tmail_ui_user/features/delegation/data/repository/delegated_account_repository_impl.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/remote_exception_thrower.dart';

import 'delegated_account_repository_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DelegatedAccountApi>()])
void main() {
  final accountId = AccountId(Id('account-a'));
  final delegatedAccount = DelegatedAccount(id: Id('delegation-1'), username: 'owner@example.com');
  late MockDelegatedAccountApi api;
  late DelegatedAccountRepositoryImpl repository;

  setUp(() {
    api = MockDelegatedAccountApi();
    repository = DelegatedAccountRepositoryImpl(
      DelegatedAccountDatasourceImpl(api, RemoteExceptionThrower()),
    );
  });

  group('DelegatedAccountRepositoryImpl.getDelegatedAccounts', () {
    test('should return the delegated accounts of the API', () async {
      when(api.getDelegatedAccounts(accountId)).thenAnswer((_) async => [delegatedAccount]);

      expect(await repository.getDelegatedAccounts(accountId), [delegatedAccount]);
    });

    test('should rethrow the API exception', () async {
      when(api.getDelegatedAccounts(accountId)).thenThrow(StateError('refused'));

      await expectLater(repository.getDelegatedAccounts(accountId), throwsA(isA<StateError>()));
    });
  });

  group('DelegatedAccountRepositoryImpl.removeDelegatedAccount', () {
    test('should remove the delegation through the API', () async {
      when(api.removeDelegatedAccount(accountId, delegatedAccount.id)).thenAnswer((_) async {});

      await repository.removeDelegatedAccount(accountId, delegatedAccount.id);

      verify(api.removeDelegatedAccount(accountId, delegatedAccount.id)).called(1);
    });

    test('should rethrow the API exception', () async {
      when(api.removeDelegatedAccount(accountId, delegatedAccount.id)).thenThrow(StateError('refused'));

      await expectLater(
        repository.removeDelegatedAccount(accountId, delegatedAccount.id),
        throwsA(isA<StateError>()),
      );
    });
  });
}
