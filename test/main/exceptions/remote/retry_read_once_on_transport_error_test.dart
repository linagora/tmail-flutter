import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote/retry_read_once_on_transport_error.dart';

void main() {
  test('waits 500 ms before the second attempt', () {
    fakeAsync((async) {
      var calls = 0;
      retryReadOnceOnTransportError<int>(() async {
        if (calls++ == 0) throw const SocketError();
        return 1;
      });

      async.elapse(const Duration(milliseconds: 499));
      expect(calls, 1);

      async.elapse(const Duration(milliseconds: 1));
      expect(calls, 2);
    });
  });
}
