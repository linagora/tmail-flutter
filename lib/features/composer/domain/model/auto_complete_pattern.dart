
import 'package:equatable/equatable.dart';

class AutoCompletePattern with EquatableMixin {

  final String? word;
  final int? limit;
  final String? orderBy;
  final bool? isAll;

  AutoCompletePattern({
    this.word,
    this.limit,
    this.orderBy,
    this.isAll,
  });

  @override
  List<Object?> get props => [word, limit, orderBy, isAll];

}