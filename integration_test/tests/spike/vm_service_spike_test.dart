import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('vm service uri is reachable from inside the app', ($) async {
    var info = await Service.getInfo();
    if (info.serverWebSocketUri == null) {
      info = await Service.controlWebServer(enable: true);
    }
    // ignore: avoid_print
    print('SPIKE_VM_SERVICE_URI=${info.serverWebSocketUri}');
    expect(info.serverWebSocketUri, isNotNull);
  });
}
