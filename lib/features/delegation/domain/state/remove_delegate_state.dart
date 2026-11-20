import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/remove_delegate_result.dart';

class RemovingDelegate extends LoadingState {}

class RemoveDelegateSuccess extends UIState {
  final RemoveDelegateResult result;

  RemoveDelegateSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class RemoveDelegateFailure extends FeatureFailure {
  RemoveDelegateFailure(Object? exception) : super(exception: exception);
}
