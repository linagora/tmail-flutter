
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:labels/model/label.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/create_new_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/edit_label_interactor.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/creator_action_type.dart';

class RulesFilterCreatorArguments with EquatableMixin {
  final AccountId accountId;
  final Session session;
  final bool isLabelAvailable;
  final CreatorActionType actionType;
  final TMailRule? tMailRule;
  final EmailAddress? emailAddress;
  final PresentationMailbox? mailboxDestination;
  final List<Label>? allLabels;
  final CreateNewLabelInteractor? createNewLabelInteractor;
  final EditLabelInteractor? editLabelInteractor;

  RulesFilterCreatorArguments(
    this.accountId,
    this.session,
    {
      this.actionType = CreatorActionType.create,
      this.isLabelAvailable = false,
      this.tMailRule,
      this.emailAddress,
      this.mailboxDestination,
      this.allLabels,
      this.createNewLabelInteractor,
      this.editLabelInteractor,
    }
  );

  @override
  List<Object?> get props => [
    accountId,
    actionType,
    session,
    isLabelAvailable,
    tMailRule,
    emailAddress,
    mailboxDestination,
    allLabels,
    createNewLabelInteractor,
    editLabelInteractor,
  ];
}