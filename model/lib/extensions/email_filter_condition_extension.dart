
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';

extension EmailFilterConditionExtension on EmailFilterCondition {

  bool get hasCondition {
    return inMailbox != null ||
        inMailboxOtherThan?.isNotEmpty == true ||
        before != null ||
        after != null ||
        minSize != null ||
        maxSize != null ||
        allInThreadHaveKeyword?.isNotEmpty == true ||
        someInThreadHaveKeyword?.isNotEmpty == true ||
        noneInThreadHaveKeyword?.isNotEmpty == true ||
        hasKeyword?.isNotEmpty == true ||
        notKeyword?.isNotEmpty == true ||
        hasAttachment != null ||
        text?.isNotEmpty == true ||
        from?.isNotEmpty == true ||
        to?.isNotEmpty == true ||
        cc?.isNotEmpty == true ||
        bcc?.isNotEmpty == true ||
        subject?.isNotEmpty == true ||
        body?.isNotEmpty == true ||
        header?.isNotEmpty == true;
  }
}