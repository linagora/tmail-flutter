
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/email_extension.dart';

enum FilterMessageOption {
  all,
  unread,
  attachments,
  starred,
}

extension FilterMessageOptionExtension on FilterMessageOption {

  bool filterPresentationEmail(PresentationEmail email) {
    switch(this) {
      case FilterMessageOption.all:
        return true;
      case FilterMessageOption.unread:
        return !email.hasRead;
      case FilterMessageOption.attachments:
        return email.withAttachments;
      case FilterMessageOption.starred:
        return email.hasStarred;
    }
  }

  bool filterEmail(Email email) {
    switch(this) {
      case FilterMessageOption.all:
        return true;
      case FilterMessageOption.unread:
        return !email.hasRead;
      case FilterMessageOption.attachments:
        return email.withAttachments;
      case FilterMessageOption.starred:
        return email.hasStarred;
    }
  }
}