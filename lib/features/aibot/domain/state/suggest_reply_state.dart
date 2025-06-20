import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class SuggestReplyLoading extends UIState {
  @override
  List<Object?> get props => [];
}

class SuggestReplySuccess extends UIState {
  final String suggestion;

  SuggestReplySuccess(this.suggestion);

  @override
  List<Object?> get props => [suggestion];
}

class SuggestReplyFailure extends FeatureFailure {
  SuggestReplyFailure(dynamic exception) : super(exception: exception);
}
