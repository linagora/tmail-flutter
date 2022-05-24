
import 'package:equatable/equatable.dart';

class RecentSearch with EquatableMixin {
  final String value;
  final DateTime creationDate;

  RecentSearch(this.value, this.creationDate);

  factory RecentSearch.now(String word) {
    return RecentSearch(word, DateTime.now());
  }

  @override
  List<Object?> get props => [value, creationDate];
}