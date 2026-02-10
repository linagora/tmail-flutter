import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/labels/domain/model/label_changes_result.dart';

class GettingLabelChanges extends LoadingState {}

class GetLabelChangesSuccess extends UIState {
  final LabelChangesResult changesResult;

  GetLabelChangesSuccess(this.changesResult);

  @override
  List<Object> get props => [changesResult];
}

class GetLabelChangesFailure extends FeatureFailure {
  GetLabelChangesFailure(dynamic exception) : super(exception: exception);
}
