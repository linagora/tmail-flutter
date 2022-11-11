
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/creator_action_type.dart';

class RulesFilterCreatorArguments with EquatableMixin {
  final AccountId accountId;
  final Session session;
  final CreatorActionType actionType;
  final TMailRule? tMailRule;
  final EmailAddress? emailAddress;

  RulesFilterCreatorArguments(this.accountId, this.session, {
    this.actionType = CreatorActionType.create,
    this.tMailRule,
    this.emailAddress
  });

  @override
  List<Object?> get props => [accountId, actionType, session, tMailRule, emailAddress];
}