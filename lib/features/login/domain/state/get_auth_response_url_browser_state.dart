import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GetAuthResponseUrlBrowserLoading extends LoadingState {}

class GetAuthResponseUrlBrowserSuccess extends UIState {
  final String authResponseUrl;

  GetAuthResponseUrlBrowserSuccess(this.authResponseUrl);
}

class GetAuthResponseUrlBrowserFailure extends FeatureFailure {

  GetAuthResponseUrlBrowserFailure(dynamic exception) : super(exception: exception);
}