import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class PreviewingEmailFromEmlFile extends LoadingState {}

class PreviewEmailFromEmlFileSuccess extends UIState {

  final String storeKey;

  PreviewEmailFromEmlFileSuccess(this.storeKey);

  @override
  List<Object?> get props => [storeKey];
}

class PreviewEmailFromEmlFileFailure extends FeatureFailure {

  PreviewEmailFromEmlFileFailure(dynamic exception) : super(exception: exception);
}