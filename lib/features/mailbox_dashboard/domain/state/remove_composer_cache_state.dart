import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class RemoveLocalEmailDraftSuccess extends UIState {

  RemoveLocalEmailDraftSuccess();

  @override
  List<Object?> get props => [];
}

class RemoveLocalEmailDraftFailure extends FeatureFailure {

  RemoveLocalEmailDraftFailure(dynamic exception) : super(exception: exception);
}