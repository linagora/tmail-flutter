import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StartDownloadMessageAsEML extends LoadingState {}

class DownloadMessageAsEMLSuccess extends UIState {}

class DownloadMessageAsEMLFailure extends FeatureFailure {

  DownloadMessageAsEMLFailure(dynamic exception) : super(exception: exception);
}