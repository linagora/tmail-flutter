import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GettingPinAttachmentStatus extends LoadingState {}

class GetPinAttachmentStatusSuccess extends UIState {
  final bool isEnabled;

  GetPinAttachmentStatusSuccess(this.isEnabled);

  @override
  List<Object?> get props => [isEnabled];
}

class GetPinAttachmentStatusFailure extends FeatureFailure {
  GetPinAttachmentStatusFailure(dynamic exception) : super(exception: exception,);
}