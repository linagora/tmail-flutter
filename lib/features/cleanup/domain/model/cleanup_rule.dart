
import 'package:equatable/equatable.dart';

abstract class CleanupRule with EquatableMixin {

  CleanupRule();

  @override
  List<Object?> get props => [];
}

class Duration with EquatableMixin {
  static final defaultCacheInternal = Duration(10);

  final int countDay;

  Duration(this.countDay);

  @override
  List<Object?> get props => [countDay];
}