import 'package:equatable/equatable.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';

abstract class RuleFilterActionArguments with EquatableMixin {
  final EmailRuleFilterAction? action;

  RuleFilterActionArguments({
    this.action,
  });

  factory RuleFilterActionArguments.newAction(EmailRuleFilterAction? action) {
    switch (action) {
      case EmailRuleFilterAction.maskAsSeen:
        return MarkAsSeenActionArguments();
      case EmailRuleFilterAction.markAsSpam:
        return MarAsSpamActionArguments();
      case EmailRuleFilterAction.forwardTo:
        return ForwardActionArguments();
      case EmailRuleFilterAction.moveMessage:
        return MoveMessageActionArguments();
      case EmailRuleFilterAction.rejectIt:
        return RejectItActionArguments();
      case EmailRuleFilterAction.starIt:
        return StarItActionArguments();
      default:
        return EmptyRuleFilterActionArguments();
    }
  }

  @override
  List<Object?> get props => [
    action,
  ];
}

class ForwardActionArguments extends RuleFilterActionArguments {
  final String? forwardEmail;

  ForwardActionArguments({
    this.forwardEmail,
  }) : super(
    action: EmailRuleFilterAction.forwardTo,
  );

  @override
  List<Object?> get props => [
    forwardEmail,
  ];
}

class MarkAsSeenActionArguments extends RuleFilterActionArguments {
  MarkAsSeenActionArguments() : super(
    action: EmailRuleFilterAction.maskAsSeen,
  );
}

class MarAsSpamActionArguments extends RuleFilterActionArguments {
  MarAsSpamActionArguments() : super(
    action: EmailRuleFilterAction.markAsSpam,
  );
}

class MoveMessageActionArguments extends RuleFilterActionArguments {
  final PresentationMailbox? mailbox;

  MoveMessageActionArguments({
    this.mailbox,
  }) : super(
    action: EmailRuleFilterAction.moveMessage,
  );

  @override
  List<Object?> get props => [
    mailbox,
  ];
}

class RejectItActionArguments extends RuleFilterActionArguments {
  RejectItActionArguments() : super(
    action: EmailRuleFilterAction.rejectIt,
  );
}

class StarItActionArguments extends RuleFilterActionArguments {
  StarItActionArguments() : super(
    action: EmailRuleFilterAction.starIt,
  );
}

class EmptyRuleFilterActionArguments extends RuleFilterActionArguments {
  EmptyRuleFilterActionArguments() : super(
    action: null,
  );
}
