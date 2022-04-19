import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';

class GetEmailRequest with EquatableMixin {
  final AccountId accountId;
  final UnsignedInt? limit;
  final Set<Comparator>? sort;
  final Filter? filter;
  final Properties? properties;
  final EmailId? lastEmailId;

  GetEmailRequest(this.accountId, {
    this.limit,
    this.sort,
    this.filter,
    this.properties,
    this.lastEmailId,
  });

  @override
  List<Object?> get props => [limit, sort, filter, properties, lastEmailId];
}