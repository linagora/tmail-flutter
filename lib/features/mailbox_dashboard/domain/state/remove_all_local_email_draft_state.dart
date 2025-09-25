import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class RemoveAllLocalEmailDraftsSuccess extends UIState {}

class RemoveAllLocalEmailDraftsFailure extends FeatureFailure {

  RemoveAllLocalEmailDraftsFailure(dynamic exception) : super(exception: exception);
}