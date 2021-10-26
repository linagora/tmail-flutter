
import 'package:equatable/equatable.dart';

class SearchQuery with EquatableMixin {
  final String value;

  SearchQuery(this.value);

  @override
  List<Object?> get props => [value];
}