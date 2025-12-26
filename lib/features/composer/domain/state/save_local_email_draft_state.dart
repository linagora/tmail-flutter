import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class SaveLocalEmailDraftSuccess extends UIState {}

class SaveLocalEmailDraftFailure extends FeatureFailure {

  SaveLocalEmailDraftFailure(dynamic exception) : super(exception: exception);
}