import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';

class QuotasResponse with EquatableMixin {
  final AccountId accountId;
  final State state;
  final List<Quota> quotas;
  final List<Id>? notFound;

  QuotasResponse({
    required this.accountId,
    required this.state,
    required this.quotas,
    this.notFound,
  });

  bool hasData() {
    return quotas.isNotEmpty;
  }

  @override
  List<Object?> get props => [
    quotas,
    state,
    notFound,
  ];
}
