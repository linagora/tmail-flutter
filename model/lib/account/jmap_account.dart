
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';

class JmapAccount with EquatableMixin {

  final AccountId accountId;
  final AccountName name;
  final bool isPersonal;
  final bool isReadOnly;
  final Map<CapabilityIdentifier, CapabilityProperties> accountCapabilities;

  JmapAccount(
    this.accountId,
    this.name,
    this.isPersonal,
    this.isReadOnly,
    this.accountCapabilities,
  );

  @override
  List<Object> get props => [
    accountId,
    name,
    isPersonal,
    isReadOnly,
    accountCapabilities
  ];
}