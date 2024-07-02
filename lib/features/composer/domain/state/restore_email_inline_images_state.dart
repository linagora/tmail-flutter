import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class RestoringEmailInlineImages extends LoadingState {}

class RestoreEmailInlineImagesSuccess extends UIState {
  final String emailContent;

  RestoreEmailInlineImagesSuccess(this.emailContent);

  @override
  List<Object?> get props => [emailContent];
}

class RestoreEmailInlineImagesFailure extends FeatureFailure {

  RestoreEmailInlineImagesFailure({super.exception});
}