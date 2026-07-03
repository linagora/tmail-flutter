import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:tmail_ui_user/features/login/domain/state/authenticate_oidc_on_browser_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authenticate_oidc_on_browser_interactor.dart';

// Reuse the AuthenticationOIDCRepository mock generated for the sibling test.
import 'try_guessing_web_finger_interactor_test.mocks.dart';

void main() {
  late MockAuthenticationOIDCRepository repository;
  late AuthenticateOidcOnBrowserInteractor interactor;

  OIDCConfiguration configWith(bool ssoConfirmed) => OIDCConfiguration(
        authority: 'https://sso.example.com',
        clientId: 'client-id',
        scopes: const ['openid'],
        ssoConfirmed: ssoConfirmed,
      );

  setUp(() {
    repository = MockAuthenticationOIDCRepository();
    interactor = AuthenticateOidcOnBrowserInteractor(repository);
    when(repository.authenticateOidcOnBrowser(any, any, any, any))
        .thenThrow(Exception('browser redirect failed'));
  });

  AuthenticateOidcOnBrowserFailure emittedFailure(List states) => states
      .map((either) => either.fold((failure) => failure, (_) => null))
      .whereType<AuthenticateOidcOnBrowserFailure>()
      .single;

  test('WHEN authentication fails THEN the failure carries the config ssoConfirmed == true', () async {
    final states = await interactor.execute(configWith(true)).toList();

    expect(emittedFailure(states).ssoConfirmed, isTrue);
  });

  test('WHEN authentication fails THEN the failure carries the config ssoConfirmed == false', () async {
    final states = await interactor.execute(configWith(false)).toList();

    expect(emittedFailure(states).ssoConfirmed, isFalse);
  });
}
