import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

class GetEmailRequest with EquatableMixin {
  final Session session;
  final AccountId accountId;
  final UnsignedInt? limit;
  final int? position;
  final Set<Comparator>? sort;
  final Filter? filter;
  final FilterMessageOption? filterOption;
  final Properties? properties;
  final EmailId? lastEmailId;
  final bool useCache;

  GetEmailRequest(
    this.session,
    this.accountId,
    {
      this.limit,
      this.position,
      this.sort,
      this.filter,
      this.filterOption,
      this.properties,
      this.lastEmailId,
      this.useCache = true,
    }
  );

  @override
  List<Object?> get props => [
    session,
    accountId,
    limit,
    position,
    sort,
    filter,
    properties,
    lastEmailId,
    filterOption,
    useCache,
  ];
}