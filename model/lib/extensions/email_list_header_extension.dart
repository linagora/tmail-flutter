import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header_value.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';

/// RFC 8621 §4.1.2.3: RFC 2369 `List-*` fields allow only the Raw and URLs
/// forms, never `asText`.
class ListHeaderIdentifier {
  static final listPost = IndividualHeaderIdentifier('header:List-Post');
  static final listUnsubscribe = IndividualHeaderIdentifier('header:List-Unsubscribe');
}

extension EmailListHeaderExtension on Email {
  TextHeaderValue? get listPostHeaderValue =>
      _listHeaderValue(ListHeaderIdentifier.listPost) ?? listPostHeader;

  TextHeaderValue? get listUnsubscribeHeaderValue =>
      _listHeaderValue(ListHeaderIdentifier.listUnsubscribe) ?? listUnsubscribeHeader;

  TextHeaderValue? _listHeaderValue(IndividualHeaderIdentifier id) {
    final value = individualHeaders[id];
    if (value is RawHeaderValue && value.value != null) {
      return TextHeaderValue(value.value);
    }
    if (value is TextHeaderValue && value.value != null) return value;
    return null;
  }
}
