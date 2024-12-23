import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StartDeleteEmailPermanently extends UIState {}

class DeleteEmailPermanentlySuccess extends UIState {}

class DeleteEmailPermanentlyFailure extends FeatureFailure {

  DeleteEmailPermanentlyFailure(dynamic exception) : super(exception: exception);
}