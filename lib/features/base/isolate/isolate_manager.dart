import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:core/utils/app_logger.dart';

abstract class IsolateManager {
  ReceivePort? _eventReceivePort;
  StreamSubscription? _streamSubscription;

  String get isolateIdentityName;

  void initial({
    Function(dynamic)? onData,
    Function? onError,
    Function()? onDone,
  }) {
    try {
      release();
      final receivePort = ReceivePort();
      final registered = IsolateNameServer.registerPortWithName(
        receivePort.sendPort,
        isolateIdentityName,
      );
      if (!registered) {
        receivePort.close();
        logWarning(
          'IsolateManager::initial(): cannot register $isolateIdentityName',
        );
        return;
      }
      _eventReceivePort = receivePort;
      _streamSubscription = receivePort.listen(
        onData,
        onError: onError,
        onDone: onDone,
      );
    } catch (e) {
      logWarning('IsolateManager::initial():EXCEPTION: $e');
    }
  }

  void addEvent(Object? value) {
    log('IsolateManager::addEvent():value: $value');
    try {
      final sendPort = IsolateNameServer.lookupPortByName(isolateIdentityName);
      if (sendPort != null) {
        sendPort.send(value);
      } else {
        logWarning('IsolateManager::addEvent(): sendPort is null');
      }
    } catch (e) {
      logWarning('IsolateManager::addEvent():EXCEPTION: $e');
    }
  }

  void release() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _eventReceivePort?.close();
    _eventReceivePort = null;
    IsolateNameServer.removePortNameMapping(isolateIdentityName);
  }
}
