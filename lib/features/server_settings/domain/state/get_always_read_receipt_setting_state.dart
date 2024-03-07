import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GettingAlwaysReadReceiptSetting extends LoadingState {}

class GetAlwaysReadReceiptSettingSuccess extends UIState {
  final bool alwaysReadReceiptEnabled;

  GetAlwaysReadReceiptSettingSuccess({required this.alwaysReadReceiptEnabled});

  @override
  List<Object?> get props => [alwaysReadReceiptEnabled];
}

class GetAlwaysReadReceiptSettingFailure extends FeatureFailure {
  GetAlwaysReadReceiptSettingFailure(dynamic exception) 
    : super(exception: exception);
}