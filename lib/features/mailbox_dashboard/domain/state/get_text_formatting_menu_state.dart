import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GettingTextFormattingMenuState extends LoadingState {}

class GetTextFormattingMenuStateSuccess extends UIState {
  final bool isDisplayed;

  GetTextFormattingMenuStateSuccess(this.isDisplayed);

  @override
  List<Object?> get props => [isDisplayed];
}

class GetTextFormattingMenuStateFailure extends FeatureFailure {
  GetTextFormattingMenuStateFailure(dynamic exception) : super(exception: exception);
}
