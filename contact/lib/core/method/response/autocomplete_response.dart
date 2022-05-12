import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/method/method_response.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';

abstract class AutoCompleteResponse<T> extends ResponseRequiringAccountId {
  final List<T> list;
  final UnsignedInt? limit;

  AutoCompleteResponse(
    AccountId accountId,
    this.list,
    this.limit,
  ) : super(accountId);
}