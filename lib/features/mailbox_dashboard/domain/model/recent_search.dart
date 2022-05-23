
import 'package:equatable/equatable.dart';

class RecentSearch with EquatableMixin {
  final String value;
  final DateTime creationDate;

  RecentSearch(this.value, this.creationDate);

  @override
  List<Object?> get props => [value, creationDate];
}