import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';

class GettingLabelSettingState extends LoadingState {}

class GetLabelSettingStateSuccess extends UIState {
  final bool isEnabled;
  final AccountId accountId;

  GetLabelSettingStateSuccess(this.isEnabled, this.accountId);

  @override
  List<Object> get props => [isEnabled, accountId];
}

class GetLabelSettingStateFailure extends FeatureFailure {
  GetLabelSettingStateFailure(dynamic exception) : super(exception: exception);
}
