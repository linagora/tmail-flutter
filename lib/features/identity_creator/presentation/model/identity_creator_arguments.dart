
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/model.dart';

class IdentityCreatorArguments with EquatableMixin {
  final AccountId accountId;
  final UserProfile userProfile;

  IdentityCreatorArguments(this.accountId, this.userProfile);

  @override
  List<Object?> get props => [accountId, userProfile];
}