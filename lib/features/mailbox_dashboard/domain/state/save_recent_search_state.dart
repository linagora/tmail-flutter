import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class SaveRecentSearchSuccess extends UIState {}

class SaveRecentSearchFailure extends FeatureFailure {

  SaveRecentSearchFailure(dynamic exception) : super(exception: exception);
}