import 'package:contact/contact/model/autocomplete_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/calendar_event_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:jmap_dart_client/jmap/core/capability/core_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/default_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/empty_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/mail_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/mdn_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/submission_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/vacation_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/web_socket_ticket_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/websocket_capability.dart';
import 'package:labels/model/labels_capability.dart';
import 'package:model/saas/saas_account_capability.dart';
import 'package:model/support/contact_support_capability.dart';
import 'package:model/upload/upload_from_url_capability.dart';
import 'package:scribe/scribe/ai/presentation/model/ai_capability.dart';

class CapabilityPropertiesConverter {

  // Dispatch table keyed by runtime type keeps this out of an ever-growing if-else chain.
  static final Map<Type, Map<String, dynamic>? Function(CapabilityProperties)> _converters = {
    CoreCapability: (properties) => (properties as CoreCapability).toJson(),
    MailCapability: (properties) => (properties as MailCapability).toJson(),
    SubmissionCapability: (properties) => (properties as SubmissionCapability).toJson(),
    VacationCapability: (properties) => (properties as VacationCapability).toJson(),
    CalendarEventCapability: (properties) => (properties as CalendarEventCapability).toJson(),
    WebSocketCapability: (properties) => (properties as WebSocketCapability).toJson(),
    WebSocketTicketCapability: (properties) => (properties as WebSocketTicketCapability).toJson(),
    MdnCapability: (properties) => (properties as MdnCapability).toJson(),
    AutocompleteCapability: (properties) => (properties as AutocompleteCapability).toJson(),
    ContactSupportCapability: (properties) => (properties as ContactSupportCapability).toJson(),
    SaaSAccountCapability: (properties) => (properties as SaaSAccountCapability).toJson(),
    AICapability: (properties) => (properties as AICapability).toJson(),
    LabelsCapability: (properties) => (properties as LabelsCapability).toJson(),
    UploadFromUrlCapability: (properties) => (properties as UploadFromUrlCapability).toJson(),
    DefaultCapability: (properties) => (properties as DefaultCapability).properties,
    EmptyCapability: (properties) => (properties as EmptyCapability).toJson(),
  };

  Map<String, dynamic>? toJson(CapabilityProperties properties) {
    final converter = _converters[properties.runtimeType];
    return converter?.call(properties);
  }
}
