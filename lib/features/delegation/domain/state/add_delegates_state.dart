import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/add_delegates_result.dart';

class AddingDelegates extends LoadingState {}

class AddDelegatesSuccess extends UIState {
  final AddDelegatesResult result;

  AddDelegatesSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class AddDelegatesFailure extends FeatureFailure {
  AddDelegatesFailure(dynamic exception) : super(exception: exception);
}
