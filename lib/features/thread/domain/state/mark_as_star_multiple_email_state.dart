import 'package:core/core.dart';
import 'package:model/model.dart';

class MarkAsStarMultipleEmailAllSuccess extends UIState {
  final int countMarkStarSuccess;
  final MarkStarAction markStarAction;

  MarkAsStarMultipleEmailAllSuccess(this.countMarkStarSuccess, this.markStarAction);

  @override
  List<Object?> get props => [countMarkStarSuccess, markStarAction];
}

class MarkAsStarMultipleEmailAllFailure extends FeatureFailure {
  final MarkStarAction markStarAction;

  MarkAsStarMultipleEmailAllFailure(this.markStarAction);

  @override
  List<Object> get props => [markStarAction];
}

class MarkAsStarMultipleEmailHasSomeEmailFailure extends UIState {
  final int countMarkStarSuccess;
  final MarkStarAction markStarAction;

  MarkAsStarMultipleEmailHasSomeEmailFailure(this.countMarkStarSuccess, this.markStarAction);

  @override
  List<Object> get props => [countMarkStarSuccess, markStarAction];
}

class MarkAsStarMultipleEmailFailure extends FeatureFailure {
  final dynamic exception;
  final MarkStarAction markStarAction;

  MarkAsStarMultipleEmailFailure(this.exception, this.markStarAction);

  @override
  List<Object> get props => [exception, markStarAction];
}