
import 'package:equatable/equatable.dart';

class SearchQuery with EquatableMixin {
  final String value;

  SearchQuery(this.value);

  factory SearchQuery.initial() {
    return SearchQuery('');
  }

  @override
  List<Object?> get props => [value];
}