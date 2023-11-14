import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:jmap_dart_client/jmap/core/capability/core_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/default_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/empty_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/mail_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/mdn_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/submission_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/vacation_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/websocket_capability.dart';

class CapabilityPropertiesConverter {

  Map<String, dynamic>? toJson(CapabilityProperties properties) {
    if (properties is CoreCapability) {
      return properties.toJson();
    } else if (properties is MailCapability) {
      return properties.toJson();
    } else if (properties is SubmissionCapability) {
      return properties.toJson();
    } else if (properties is VacationCapability) {
      return properties.toJson();
    } else if (properties is WebSocketCapability) {
      return properties.toJson();
    } else if (properties is MdnCapability) {
      return properties.toJson();
    } else if (properties is DefaultCapability) {
      return properties.properties;
    } else if (properties is EmptyCapability) {
      return properties.toJson();
    } else {
      return null;
    }
  }
}