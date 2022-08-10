
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/creator_action_type.dart';

class RulesFilterCreatorArguments with EquatableMixin {
  final AccountId accountId;
  final CreatorActionType actionType;

  RulesFilterCreatorArguments(this.accountId, {
    this.actionType = CreatorActionType.create
  });

  @override
  List<Object?> get props => [accountId, actionType];
}