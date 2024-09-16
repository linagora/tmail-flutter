
import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:core/utils/app_logger.dart';

abstract class IsolateManager {

  final _eventReceivePort = ReceivePort();
  StreamSubscription? _streamSubscription;

  String get isolateIdentityName;

  void initial({
    Function(dynamic)? onData,
    Function? onError,
    Function()? onDone,
  }) {
    try {
      IsolateNameServer.registerPortWithName(_eventReceivePort.sendPort, isolateIdentityName);
      _streamSubscription = _eventReceivePort.listen(onData, onError: onError, onDone: onDone);
    } catch (e) {
      logError('IsolateManager::initial():EXCEPTION: $e');
    }
  }

  void addEvent(Object? value) {
    log('IsolateManager::addEvent():value: $value');
    try {
      final sendPort = IsolateNameServer.lookupPortByName(isolateIdentityName);
      if (sendPort != null) {
        sendPort.send(value);
      } else {
        logError('IsolateManager::addEvent(): sendPort is null');
      }
    } catch (e) {
      logError('IsolateManager::addEvent():EXCEPTION: $e');
    }
  }

  void release() {
    _eventReceivePort.close();
    _streamSubscription?.cancel();
  }
}