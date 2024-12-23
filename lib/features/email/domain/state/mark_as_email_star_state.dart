import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/mark_star_action.dart';

class MarkAsStarEmailSuccess extends UIState {
  final MarkStarAction markStarAction;

  MarkAsStarEmailSuccess(this.markStarAction);

  @override
  List<Object?> get props => [markStarAction];
}

class MarkAsStarEmailFailure extends FeatureFailure {
  final MarkStarAction markStarAction;

  MarkAsStarEmailFailure(this.markStarAction, {dynamic exception}) : super(exception: exception);

  @override
  List<Object?> get props => [markStarAction, ...super.props];
}