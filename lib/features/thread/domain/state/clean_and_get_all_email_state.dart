import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class CleanAndGetAllEmailLoading extends LoadingState {}

class CleanAndGetAllEmailFailure extends FeatureFailure {

  CleanAndGetAllEmailFailure(dynamic exception) : super(exception: exception);
}