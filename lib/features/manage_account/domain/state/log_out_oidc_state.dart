
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class LogoutOidcSuccess extends UIState {}

class LogoutOidcFailure extends FeatureFailure {

  LogoutOidcFailure(dynamic exception) : super(exception: exception);
}