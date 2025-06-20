import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class GettingThreadById extends LoadingState {
  final bool updateCurrentThreadDetail;

  GettingThreadById({this.updateCurrentThreadDetail = false});

  @override
  List<Object> get props => [updateCurrentThreadDetail];
}

class GetThreadByIdSuccess extends UIState {
  final List<EmailId> emailIds;
  final bool updateCurrentThreadDetail;

  GetThreadByIdSuccess(this.emailIds, {this.updateCurrentThreadDetail = false});

  @override
  List<Object> get props => [emailIds, updateCurrentThreadDetail];
}

class PreloadEmailIdsInThreadSuccess extends GetThreadByIdSuccess {
  PreloadEmailIdsInThreadSuccess(super.emailIds);
}

class GetThreadByIdFailure extends FeatureFailure {
  GetThreadByIdFailure({
    super.exception,
    super.onRetry,
    required this.updateCurrentThreadDetail,
  });

  final bool updateCurrentThreadDetail;

  @override
  List<Object?> get props => [...super.props, updateCurrentThreadDetail];
}