import 'package:json_annotation/json_annotation.dart';

enum WorkplaceAction {
  @JsonValue('PICK')
  pick;
}

enum WorkplacePermission {
  @JsonValue('GET')
  get;
}

enum WorkplaceDataRequestType {
  @JsonValue('io.cozy.intents')
  intents;
}

enum WorkplaceAttributesRequestType {
  @JsonValue('io.cozy.files')
  files;
}

enum WorkplaceExchangeType {
  admin,
  app;
}