import 'package:core/data/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/oidc/request/oidc_request.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_error.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';

import 'oidc_http_client_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DioClient>()])
void main() {
  final dioClient = MockDioClient();
  final oidcHttpClient = OIDCHttpClient(dioClient);
  final requestOptions = RequestOptions();
  final oidcRequest = OIDCRequest(baseUrl: '', resourceUrl: '');

  group('oidc http client test:', () {
    test(
      'should throw CanNotFoundOIDCLinks '
      'when checkOIDCIsAvailable() is called '
      'and dioClient throw DioException '
      'and status code is 404',
    () {
      // arrange
      when(dioClient.get(any)).thenThrow(DioException(
        requestOptions: requestOptions,
        response: Response(requestOptions: requestOptions, statusCode: 404)));

      // assert
      expect(
        () => oidcHttpClient.checkOIDCIsAvailable(oidcRequest),
        throwsA(isA<CanNotFoundOIDCLinks>()));
    });  

    test(
      'should throw CanRetryOIDCException '
      'when checkOIDCIsAvailable() is called '
      'and dioClient throw DioException '
      'and status code is not 404',
    () {
      // arrange
      when(dioClient.get(any)).thenThrow(DioException(
        requestOptions: requestOptions,
        response: Response(requestOptions: requestOptions, statusCode: 403)));

      // assert
      expect(
        () => oidcHttpClient.checkOIDCIsAvailable(oidcRequest),
        throwsA(isA<CanRetryOIDCException>()));
    });

    test(
      'should throw CanRetryOIDCException '
      'when checkOIDCIsAvailable() is called '
      'and dioClient throw exception that is not DioException',
    () {
      // arrange
      when(dioClient.get(any)).thenThrow(Exception());

      // assert
      expect(
        () => oidcHttpClient.checkOIDCIsAvailable(oidcRequest),
        throwsA(isA<CanRetryOIDCException>()));
    });
  });
}