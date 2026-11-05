import 'dart:developer';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
// ignore: depend_on_referenced_packages
import 'package:vm_service/vm_service_io.dart';

void main() {
  patrolTest('vm service uri is reachable from inside the app', ($) async {
    var info = await Service.getInfo();
    if (info.serverWebSocketUri == null) {
      info = await Service.controlWebServer(enable: true);
    }
    // ignore: avoid_print
    print('SPIKE_VM_SERVICE_URI=${info.serverWebSocketUri}');
    expect(info.serverWebSocketUri, isNotNull);

    // ignore: avoid_print
    print('SPIKE_STAGE connect');
    final vm = await vmServiceConnectUri(info.serverWebSocketUri.toString())
        .timeout(const Duration(seconds: 30));
    try {
      final isolateId = Service.getIsolateId(Isolate.current)!;
      final sw = Stopwatch()..start();
      // ignore: avoid_print
      print('SPIKE_STAGE allocation_profile');
      final p = await vm
          .getAllocationProfile(isolateId, gc: true)
          .timeout(const Duration(seconds: 60));
      final top = [...p.members!]
        ..sort((a, b) => (b.bytesCurrent ?? 0).compareTo(a.bytesCurrent ?? 0));
      // ignore: avoid_print
      print('SPIKE_ALLOC ms=${sw.elapsedMilliseconds} '
          'heap=${p.memoryUsage?.heapUsage} '
          'ext=${p.memoryUsage?.externalUsage} '
          'classes=${p.members!.length} '
          'top=${top.take(5).map((m) => '${m.classRef?.name}:${m.bytesCurrent}').join(',')}');
      expect(p.members, isNotEmpty);
    } finally {
      await vm.dispose().timeout(const Duration(seconds: 10));
    }
  });
}
