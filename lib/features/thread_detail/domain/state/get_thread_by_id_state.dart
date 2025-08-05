import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_detail_info.dart';

class GettingThreadById extends LoadingState {
  final bool updateCurrentThreadDetail;

  GettingThreadById({this.updateCurrentThreadDetail = false});

  @override
  List<Object> get props => [updateCurrentThreadDetail];
}

class GetThreadByIdSuccess extends UIState {
  final List<EmailId> emailIds;
  final ThreadId? threadId;
  final bool updateCurrentThreadDetail;
  final bool skipLoadingMetadata;
  final List<EmailInThreadDetailInfo> emailsInThreadDetailInfo;

  GetThreadByIdSuccess(
    this.emailIds, {
    required this.threadId,
    this.updateCurrentThreadDetail = false,
    this.skipLoadingMetadata = false,
    this.emailsInThreadDetailInfo = const [],
  });

  @override
  List<Object?> get props => [
    emailIds,
    threadId,
    emailsInThreadDetailInfo,
    updateCurrentThreadDetail,
    skipLoadingMetadata,
  ];
}

class PreloadEmailIdsInThreadSuccess extends GetThreadByIdSuccess {
  PreloadEmailIdsInThreadSuccess(
    super.emailIds, {
    required super.threadId,
    super.emailsInThreadDetailInfo,
  });
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