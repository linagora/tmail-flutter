
import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:jmap_dart_client/jmap/core/extensions/utc_date_extension.dart';
import 'package:jmap_dart_client/jmap/core/extensions/string_extension.dart';
import 'package:jmap_dart_client/jmap/core/extensions/unsigned_int_extension.dart';

extension ListEmailExtension on List<Email> {

  List<EmailId> get listEmailIds => map((email) => email.id).whereNotNull().toList();

  Email? findEmailById(EmailId emailId) {
    try {
      return firstWhere((email) => email.id == emailId);
    } catch (e) {
      return null;
    }
  }

  void sortBy(Comparator comparator) {
    sort((email1, email2) {
      if (comparator.property == EmailComparatorProperty.receivedAt) {
        return email1.receivedAt.compareToSort(email2.receivedAt, comparator.isAscending);
      } else if (comparator.property == EmailComparatorProperty.sentAt) {
        return email1.sentAt.compareToSort(email2.sentAt, comparator.isAscending);
      } else if (comparator.property == EmailComparatorProperty.subject) {
        return email1.subject.compareToSort(email2.subject, comparator.isAscending);
      } else if (comparator.property == EmailComparatorProperty.size) {
        return email1.size.compareToSort(email2.size, comparator.isAscending);
      } else {
        return 0;
      }
    });
  }

  List<Email> sortWithResult(Comparator comparator) {
    return List.from(this..sortBy(comparator));
  }
}