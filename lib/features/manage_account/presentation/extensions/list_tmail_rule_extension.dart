
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

extension ListTMailRuleExtension on List<TMailRule> {
  List<MailboxId> get mailboxesAppendIn {
    List<MailboxId> mailboxIds = [];
    for (var rule in this) {
      mailboxIds.addAll(rule.action.appendIn.mailboxIds);
    }
    mailboxIds = mailboxIds.toSet().toList();
    log('ListTMailRuleExtension::_getAllMailboxAppendIn: mailboxIds = $mailboxIds');
    return mailboxIds;
  }
}