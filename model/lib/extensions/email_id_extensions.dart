import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/extensions/keyword_identifier_extension.dart';

extension EmailIdExtension on EmailId {
  String get asString => id.value;

  Map<Id, PatchObject> generateMapUpdateObjectUnsubscribeMail() {
    return {
      id: KeyWordIdentifierExtension.unsubscribeMail.generateUnsubscribeActionPath()
    };
  }
}