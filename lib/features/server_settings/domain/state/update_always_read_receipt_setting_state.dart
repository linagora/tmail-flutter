import 'package:core/core.dart';

class UpdatingAlwaysReadReceiptSetting extends LoadingState {}

class UpdateAlwaysReadReceiptSettingSuccess extends UIState {
  final bool isEnabled;

  UpdateAlwaysReadReceiptSettingSuccess({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class UpdateAlwaysReadReceiptSettingFailure extends FeatureFailure {
  UpdateAlwaysReadReceiptSettingFailure(dynamic exception) 
    : super(exception: exception);
}