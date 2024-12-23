import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class RemoveEmailDraftsSuccess extends UIState {}

class RemoveEmailDraftsFailure extends FeatureFailure {

  RemoveEmailDraftsFailure(dynamic exception) : super(exception: exception);
}