import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class NotificationSettingHandling extends LoadingState {}

class NotificationSettingSuccess extends UIState {}

class NotificationSettingFailure extends FeatureFailure {}