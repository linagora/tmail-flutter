import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:model/extensions/email_body_part_extension.dart';

extension SetEmailBodyPartExtension on Set<EmailBodyPart> {
  Set<EmailBodyPart> onlyUseBlobIdOrPartId() =>
      map((emailBodyPart) => emailBodyPart.onlyUseBlobIdOrPartId()).toSet();
}
