
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';

class RecentSearch with EquatableMixin {
  final String value;
  final DateTime creationDate;

  RecentSearch(this.value, this.creationDate);

  factory RecentSearch.now(String word) {
    return RecentSearch(word, DateTime.now());
  }

  String generateTupleKey(AccountId accountId, UserName userName) {
    return TupleKey(value, accountId.asString, userName.value).encodeKey;
  }

  @override
  List<Object?> get props => [value, creationDate];
}