import 'package:flutter_test/flutter_test.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_credential_interactor.dart';

class _FakeCredentialRepository implements CredentialRepository {
  _FakeCredentialRepository(this.stored);

  final AuthenticationInfoCache stored;

  @override
  Future<Uri> getBaseUrl() async => Uri.parse('https://jmap.example.com');

  @override
  Future<AuthenticationInfoCache> getAuthenticationInfoStored() async => stored;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final bobAccount = PersonalAccount(
    'bob@example.com',
    AuthenticationType.basic,
    isSelected: true,
  );

  test('a stored login of another account does not sign the current one in', () async {
    final interactor = GetCredentialInteractor(
      _FakeCredentialRepository(AuthenticationInfoCache('alice@example.com', 'alice-pw')));

    final result = await interactor.execute(personalAccount: bobAccount);

    expect(result.fold((f) => f, (s) => s), isA<GetCredentialFailure>());
  });

  test('the stored login of the current account signs it in', () async {
    final interactor = GetCredentialInteractor(
      _FakeCredentialRepository(AuthenticationInfoCache('bob@example.com', 'bob-pw')));

    final result = await interactor.execute(personalAccount: bobAccount);

    expect(result.fold((f) => f, (s) => s), isA<GetCredentialViewState>());
  });
}
