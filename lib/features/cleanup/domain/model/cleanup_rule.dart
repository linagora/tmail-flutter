
import 'package:equatable/equatable.dart';

class CleanupRule with EquatableMixin {
  final Duration cachingEmailPeriod;

  CleanupRule(this.cachingEmailPeriod);

  @override
  List<Object?> get props => [cachingEmailPeriod];
}

class Duration with EquatableMixin {
  static final defaultCacheInternal = Duration(10);

  final int countDay;

  Duration(this.countDay);

  @override
  List<Object?> get props => [countDay];
}