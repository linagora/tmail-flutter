import 'dart:ui' as flutter;

import 'package:hive_ce/hive.dart';

class FcmIsolateNameServer extends IsolateNameServer {
  const FcmIsolateNameServer();

  @override
  dynamic lookupPortByName(String name) =>
      flutter.IsolateNameServer.lookupPortByName(name);

  @override
  bool registerPortWithName(dynamic port, String name) =>
      flutter.IsolateNameServer.registerPortWithName(port, name);

  @override
  bool removePortNameMapping(String name) =>
      flutter.IsolateNameServer.removePortNameMapping(name);
}
