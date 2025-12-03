import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class SavingCompanyServerLoginInfo extends LoadingState {}

class SaveCompanyServerLoginInfoSuccess extends UIState {}

class SaveCompanyServerLoginInfoFailure extends FeatureFailure {
  SaveCompanyServerLoginInfoFailure(dynamic exception)
      : super(exception: exception);
}
