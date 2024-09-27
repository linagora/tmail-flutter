import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/web_socket_echo.dart';

void main() {
  group('web socket echo test:', () {
    group('isValid():', () {
      test(
        'should return true '
        'when json is web socket echo',
      () {
        // arrange
        final json = {
          "@type": "Response",
          "requestId": "R1",
          "methodResponses": [["Core/echo", {}, "c0"]]
        };

        // act
        final result = WebSocketEcho.isValid(json);

        // assert
        expect(result, true);
      });

      test(
        'should return false '
        'when json is not web socket echo',
      () {
        // arrange
        final json = {
          "@type": "Response",
          "requestId": "R1",
          "methodResponses": [["Core/not-echo", {}, "c0"]]
        };

        // act
        final result = WebSocketEcho.isValid(json);

        // assert
        expect(result, false);
      });
    });
  });
}