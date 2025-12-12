import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/map_keywords_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_detail_info.dart';

extension EmailInThreadDetailInfoExtension on EmailInThreadDetailInfo {
  EmailInThreadDetailInfo toggleKeyword(
    KeyWordIdentifier keyword,
    bool isRemoved,
  ) {
    return copyWith(
      keywords: isRemoved
          ? keywords.withoutKeyword(keyword)
          : keywords.withKeyword(keyword),
    );
  }
}
