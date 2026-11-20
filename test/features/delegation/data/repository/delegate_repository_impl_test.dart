import 'package:delegation/model/delegate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/delegation/data/datasource_impl/delegate_datasource_impl.dart';
import 'package:tmail_ui_user/features/delegation/data/network/delegate_api.dart';
import 'package:tmail_ui_user/features/delegation/data/repository/delegate_repository_impl.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/add_delegates_result.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/remove_delegate_result.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/remote_exception_thrower.dart';

import 'delegate_repository_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DelegateApi>()])
void main() {
  final accountId = AccountId(Id('account-a'));
  final delegate = Delegate(id: Id('delegate-1'), username: 'bob@example.com');
  final usernames = {'bob@example.com'};
  late MockDelegateApi api;
  late DelegateRepositoryImpl repository;

  setUp(() {
    api = MockDelegateApi();
    repository = DelegateRepositoryImpl(
      DelegateDatasourceImpl(api, RemoteExceptionThrower()),
    );
  });

  group('DelegateRepositoryImpl.getDelegates', () {
    test('should return the delegates of the API', () async {
      when(api.getDelegates(accountId)).thenAnswer((_) async => [delegate]);

      expect(await repository.getDelegates(accountId), [delegate]);
      verify(api.getDelegates(accountId)).called(1);
    });

    test('should rethrow the API exception', () async {
      when(api.getDelegates(accountId)).thenThrow(StateError('refused'));

      await expectLater(repository.getDelegates(accountId), throwsA(isA<StateError>()));
    });
  });

  group('DelegateRepositoryImpl.addDelegates', () {
    final addResult = AddDelegatesResult(
      addedUsernames: ['bob@example.com'],
      rejectedUsernames: {},
      delegates: [delegate],
    );

    test('should pass accountId and usernames through to the API', () async {
      when(api.addDelegates(accountId, usernames)).thenAnswer((_) async => addResult);

      expect(await repository.addDelegates(accountId, usernames), addResult);
      verify(api.addDelegates(accountId, usernames)).called(1);
    });

    test('should rethrow the API exception', () async {
      when(api.addDelegates(accountId, usernames)).thenThrow(StateError('refused'));

      await expectLater(
        repository.addDelegates(accountId, usernames),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('DelegateRepositoryImpl.removeDelegate', () {
    final removeResult = RemoveDelegateResult(removedDelegate: delegate, delegates: []);

    test('should pass accountId and delegate through to the API', () async {
      when(api.removeDelegate(accountId, delegate)).thenAnswer((_) async => removeResult);

      expect(await repository.removeDelegate(accountId, delegate), removeResult);
      verify(api.removeDelegate(accountId, delegate)).called(1);
    });

    test('should rethrow the API exception', () async {
      when(api.removeDelegate(accountId, delegate)).thenThrow(StateError('refused'));

      await expectLater(
        repository.removeDelegate(accountId, delegate),
        throwsA(isA<StateError>()),
      );
    });
  });
}
