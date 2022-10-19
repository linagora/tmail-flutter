
import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
import 'package:model/email/email_property.dart';

extension ListEmailHeaderExtension on Set<EmailHeader>? {
  bool get readReceiptHasBeenRequested {
    try {
      final headerMdn = this?.firstWhere((header) => header.name == EmailProperty.headerMdnKey);
      return headerMdn != null;
    } catch (e) {
      return false;
    }
  }
}