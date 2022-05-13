
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';

class AutoCompletePattern with EquatableMixin {

  final String word;
  final int? limit;
  final AccountId? accountId;

  AutoCompletePattern({
    required this.word,
    this.limit,
    this.accountId,
  });

  @override
  List<Object?> get props => [word, limit, accountId];

}