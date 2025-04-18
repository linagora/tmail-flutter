import 'package:tmail_ui_user/main/utils/cozy_contact.dart';

class _CozyConfigManagerStub {
  Future<void> injectCozyScript() async {
    throw UnimplementedError();
  }

  Future<void> initialize() async {
    throw UnimplementedError();
  }
}

class CozyConfig {
  static final CozyConfig _instance = CozyConfig._internal();

  factory CozyConfig() {
    return _instance;
  }

  CozyConfig._internal();

  final manager = _CozyConfigManagerStub();

  Future<bool> get isInsideCozy async {
    return false;
  }

  Future<List<CozyContact>> getCozyContacts() async {
    throw UnimplementedError();
  }

  Future<dynamic> getCozyFeatureFlag(String flagName) async {
    throw UnimplementedError();
  }
}
