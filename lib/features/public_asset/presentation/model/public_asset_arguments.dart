import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

class PublicAssetArguments with EquatableMixin {
  final Session session;
  final AccountId accountId;
  final Identity? identity;

  const PublicAssetArguments(this.session, this.accountId, {this.identity});

  @override
  List<Object?> get props => [accountId, session, identity];
}