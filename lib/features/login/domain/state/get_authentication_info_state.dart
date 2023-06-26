
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GetAuthenticationInfoLoading extends LoadingState {

  GetAuthenticationInfoLoading();

  @override
  List<Object> get props => [];
}

class GetAuthenticationInfoSuccess extends UIState {

  GetAuthenticationInfoSuccess();

  @override
  List<Object> get props => [];
}

class GetAuthenticationInfoFailure extends FeatureFailure {

  GetAuthenticationInfoFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}