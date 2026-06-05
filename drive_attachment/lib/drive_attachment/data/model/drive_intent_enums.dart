import 'package:json_annotation/json_annotation.dart';

enum DriveIntentAction {
  @JsonValue('PICK')
  pick;
}

enum DriveIntentPermission {
  @JsonValue('GET')
  get;
}
