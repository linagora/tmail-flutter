import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/method/method.dart';
import 'package:jmap_dart_client/jmap/core/method/request/query_method.dart';

abstract class AutoCompleteMethod extends MethodRequiringAccountId
    with OptionalLimit {

  final Filter filter;

  AutoCompleteMethod(AccountId accountId, this.filter) : super(accountId);
}