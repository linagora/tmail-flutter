
import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
import 'package:model/email/email_property.dart';
import 'package:model/email/twp_warning/twp_warning.dart';
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

  /// All `X-TWP-Message` warnings positioned on the message, in header order.
  ///
  /// Each warning's [TwpWarning.index] is its 0-based position among the
  /// `X-TWP-Message` headers, used to persist a per-warning dismissal keyword.
  List<TwpWarning> get twpWarnings {
    final headers = this;
    if (headers == null) return const [];

    final warnings = <TwpWarning>[];
    var index = 0;
    for (final header in headers) {
      if (header.name == EmailProperty.headerTwpMessageKey) {
        warnings.add(TwpWarning.parse(header.value, index));
        index++;
      }
    }
    return warnings;
  }
}