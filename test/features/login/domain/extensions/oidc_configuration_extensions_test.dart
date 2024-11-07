import 'package:core/data/model/query/query_parameter.dart';
import 'package:core/data/network/config/service_path.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/login/data/extensions/service_path_extension.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';


void main() {
  test('signInTWPUrl should return the correct URL with query parameters', () {
    // Arrange
    const authority = 'https://authority.example.com';
    const expectedUrl = '$authority?${OIDCConstant.postLoginRedirectUrlPathParams}=${OIDCConstant.twakeWorkplaceRedirectUrl}&app=${OIDCConstant.appParameter}';
    final service = ServicePath(authority);

    // Act
    final actualUrl = service
      .withQueryParameters([
        StringQueryParameter(
          OIDCConstant.postLoginRedirectUrlPathParams,
          OIDCConstant.twakeWorkplaceRedirectUrl,
        ),
        StringQueryParameter('app', OIDCConstant.appParameter),
      ])
      .generateEndpointPath();

    // Assert
    expect(actualUrl, equals(expectedUrl));
  });

  test('signUpTWPUrl should return the correct URL with query parameters', () {
    // Arrange
    const authority = 'https://authority.example.com';
    const expectedUrl = '$authority?${OIDCConstant.postRegisteredRedirectUrlPathParams}=${OIDCConstant.twakeWorkplaceRedirectUrl}&app=${OIDCConstant.appParameter}';
    final service = ServicePath(authority);

    // Act
    final actualUrl = service
      .withQueryParameters([
        StringQueryParameter(
          OIDCConstant.postRegisteredRedirectUrlPathParams,
          OIDCConstant.twakeWorkplaceRedirectUrl,
        ),
        StringQueryParameter('app', OIDCConstant.appParameter),
      ])
      .generateEndpointPath();

    // Assert
    expect(actualUrl, equals(expectedUrl));
  });
}
