import 'package:core/core.dart';

class UpdatingAlwaysReadReceiptSetting extends LoadingState {}

class UpdateAlwaysReadReceiptSettingSuccess extends UIState {
  final bool alwaysReadReceiptIsEnabled;

  UpdateAlwaysReadReceiptSettingSuccess({required this.alwaysReadReceiptIsEnabled});

  @override
  List<Object?> get props => [alwaysReadReceiptIsEnabled];
}

class UpdateAlwaysReadReceiptSettingFailure extends FeatureFailure {
  UpdateAlwaysReadReceiptSettingFailure(dynamic exception) 
    : super(exception: exception);
}