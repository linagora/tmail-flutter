
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:jmap_dart_client/jmap/core/extensions/utc_date_extension.dart';
import 'package:jmap_dart_client/jmap/core/extensions/string_extension.dart';
import 'package:jmap_dart_client/jmap/core/extensions/unsigned_int_extension.dart';

extension ListEmailExtension on List<Email> {

  Email? findEmailById(EmailId emailId) {
    try {
      return firstWhere((email) => email.id == emailId);
    } catch (e) {
      return null;
    }
  }

  void sortBy(Comparator comparator) {
    sort((email1, email2) {
      if (comparator.property == EmailComparatorProperty.sentAt
          || comparator.property == EmailComparatorProperty.receivedAt) {
        final emailTime1 = email1.sentAt ?? email1.receivedAt;
        final emailTime2 = email2.sentAt ?? email2.receivedAt;
        return emailTime1.compareToSort(emailTime2, comparator.isAscending);
      } if (comparator.property == EmailComparatorProperty.subject) {
        return email1.subject.compareToSort(email2.subject, comparator.isAscending);
      } if (comparator.property == EmailComparatorProperty.size) {
        return email1.size.compareToSort(email2.size, comparator.isAscending);
      } else {
        return 0;
      }
    });
  }
}