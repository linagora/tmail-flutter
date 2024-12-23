import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/mark_star_action.dart';

class LoadingMarkAsStarMultipleEmailAll extends UIState {}

class MarkAsStarMultipleEmailAllSuccess extends UIState {
  final int countMarkStarSuccess;
  final MarkStarAction markStarAction;

  MarkAsStarMultipleEmailAllSuccess(
    this.countMarkStarSuccess,
    this.markStarAction,
  );

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

  MarkAsStarMultipleEmailHasSomeEmailFailure(
    this.countMarkStarSuccess,
    this.markStarAction,
  );

  @override
  List<Object?> get props => [countMarkStarSuccess, markStarAction];
}

class MarkAsStarMultipleEmailFailure extends FeatureFailure {
  final MarkStarAction markStarAction;

  MarkAsStarMultipleEmailFailure(this.markStarAction, dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [markStarAction, exception];
}