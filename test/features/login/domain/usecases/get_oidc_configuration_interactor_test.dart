import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/response/oidc_link_dto.dart';
import 'package:model/oidc/response/oidc_response.dart';
import 'package:tmail_ui_user/features/login/domain/model/base_url_oidc_response.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_configuration_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_configuration_interactor.dart';

// Reuse the AuthenticationOIDCRepository mock generated for the sibling test.
import 'try_guessing_web_finger_interactor_test.mocks.dart';

void main() {
  late MockAuthenticationOIDCRepository repository;
  late GetOIDCConfigurationInteractor interactor;

  final rawConfig = OIDCConfiguration(
    authority: 'https://sso.example.com',
    clientId: 'client-id',
    scopes: ['openid'],
  );

  setUp(() {
    repository = MockAuthenticationOIDCRepository();
    interactor = GetOIDCConfigurationInteractor(repository);
    when(repository.getOIDCConfiguration(any)).thenAnswer((_) async => rawConfig);
    when(repository.persistOidcConfiguration(any))
        .thenAnswer((_) => Future<void>.value());
  });

  GetOIDCConfigurationSuccess emittedSuccess(List states) => states
      .map((either) => either.fold((_) => null, (success) => success))
      .whereType<GetOIDCConfigurationSuccess>()
      .single;

  test('WHEN the response comes from webFinger (a plain OIDCResponse) \n'
      'THEN the emitted and persisted config is marked ssoConfirmed == true', () async {
    // A webFinger hit — even one found by guessing the webFinger URL — is a
    // real SSO advertisement, so it must count as confirmed.
    final response = OIDCResponse('https://example.com', [
      OIDCLinkDto(
        Uri.parse('https://sso.example.com'),
        Uri.parse('https://sso.example.com'),
      ),
    ]);

    final states = await interactor.execute(response).toList();

    expect(emittedSuccess(states).oidcConfiguration.ssoConfirmed, isTrue);
    final persisted = verify(repository.persistOidcConfiguration(captureAny))
        .captured
        .single as OIDCConfiguration;
    expect(persisted.ssoConfirmed, isTrue);
  });

  test('WHEN the response is a BaseUrlOidcResponse (base-URL guess) \n'
      'THEN the emitted and persisted config is marked ssoConfirmed == false', () async {
    final response = BaseUrlOidcResponse(Uri.parse('https://example.com'));

    final states = await interactor.execute(response).toList();

    expect(emittedSuccess(states).oidcConfiguration.ssoConfirmed, isFalse);
    final persisted = verify(repository.persistOidcConfiguration(captureAny))
        .captured
        .single as OIDCConfiguration;
    expect(persisted.ssoConfirmed, isFalse);
  });
}
