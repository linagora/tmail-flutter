
import 'package:equatable/equatable.dart';

class AutoCompletePattern with EquatableMixin {

  final String? word;
  final int? limit;
  final String? orderBy;

  AutoCompletePattern({
    this.word,
    this.limit,
    this.orderBy
  });

  @override
  List<Object?> get props => [word, limit, orderBy];

}