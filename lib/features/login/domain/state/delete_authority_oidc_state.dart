import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DeleteAuthorityOidcSuccess extends UIState {}

class DeleteAuthorityOidcFailure extends FeatureFailure {

  DeleteAuthorityOidcFailure(dynamic exception) : super(exception: exception);
}