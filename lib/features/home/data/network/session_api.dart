import 'dart:async';

import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:jmap_dart_client/jmap/core/session/get_session.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

class SessionAPI {

  final HttpClient httpClient;

  SessionAPI(this.httpClient);

  Future<Session> getSession({Map<CapabilityIdentifier, CapabilityProperties Function(Map<String, dynamic>)>? converters}) async {
    final getSessionBuilder = GetSessionBuilder(httpClient);

    if (converters != null) {
      getSessionBuilder.registerCapabilityConverter(converters);
    }

    final result = await getSessionBuilder.build().execute();

    return result;
  }
}