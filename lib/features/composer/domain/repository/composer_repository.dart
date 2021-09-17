import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';

abstract class ComposerRepository {
  Future<bool> saveEmailAddresses(List<EmailAddress> listEmailAddress);

  Future<Attachment> uploadAttachment(UploadRequest uploadRequest);
}