import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class RemovingCompanyServerLoginInfo extends LoadingState {}

class RemoveCompanyServerLoginInfoSuccess extends UIState {}

class RemoveCompanyServerLoginInfoFailure extends FeatureFailure {
  RemoveCompanyServerLoginInfoFailure(dynamic exception)
      : super(exception: exception);
}
