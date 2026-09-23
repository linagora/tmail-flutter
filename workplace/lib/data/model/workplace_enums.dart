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

/// `Type=` on the upload route.
enum WorkplaceUploadType {
  file;

  String get value => name;
}

/// Automatic folders the stack finds-or-creates on upload.
enum WorkplaceMagicFolder {
  mail('io.cozy.apps/mail');

  const WorkplaceMagicFolder(this.value);

  final String value;
}

enum WorkplaceDocType {
  @JsonValue('io.cozy.files')
  files;
}

enum WorkplaceExchangeType {
  admin,
  app;
}

enum WorkplaceThemeType {
  light,
  dark;
}