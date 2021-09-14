import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';

extension KeyWordIdentifierExtension on KeyWordIdentifier {
  String generatePath() {
    return '${PatchObject.keywordsProperty}/$value';
  }
}