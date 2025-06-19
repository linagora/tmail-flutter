
import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
import 'package:model/email/email_property.dart';
import 'package:core/utils/app_logger.dart' as logger;

extension ListEmailHeaderExtension on Set<EmailHeader>? {
  bool get readReceiptHasBeenRequested {
    try {
      final headerMdn = this?.firstWhere((header) => header.name == EmailProperty.headerMdnKey);
      return headerMdn != null;
    } catch (e) {
      return false;
    }
  }

  String? get listUnsubscribe {
    final listUnsubscribe = this?.firstWhereOrNull((header) => header.name == EmailProperty.headerUnsubscribeKey);
    return listUnsubscribe?.value;
  }

  String get sMimeStatus {
    final sMimeStatus = this?.firstWhereOrNull((header) => header.name == EmailProperty.headerSMimeStatusKey);
    logger.log('ListEmailHeaderExtension::sMimeStatus: $sMimeStatus');
    return sMimeStatus?.value.trim() ?? '';
  }

  String? get listPost {
    final listPost = this?.firstWhereOrNull((header) => header.name == EmailProperty.headerListPostKey);
    return listPost?.value;
  }
}