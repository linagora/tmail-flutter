import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/mark_star_action.dart';

class LoadingMarkAsStarMultipleEmailAll extends LoadingState {}

class MarkAsStarMultipleEmailAllSuccess extends UIState {
  final int countMarkStarSuccess;
  final MarkStarAction markStarAction;
  final List<EmailId> emailIds;
  final bool isThread;

  MarkAsStarMultipleEmailAllSuccess(
    this.countMarkStarSuccess,
    this.markStarAction,
    this.emailIds, {
    this.isThread = false,
  });

  @override
  List<Object?> get props => [
        countMarkStarSuccess,
        markStarAction,
        emailIds,
        isThread,
      ];
}

class MarkAsStarMultipleEmailAllFailure extends FeatureFailure {
  final MarkStarAction markStarAction;

  MarkAsStarMultipleEmailAllFailure(this.markStarAction);

  @override
  List<Object> get props => [markStarAction];
}

class MarkAsStarMultipleEmailHasSomeEmailFailure extends UIState {
  final int countMarkStarSuccess;
  final MarkStarAction markStarAction;
  final List<EmailId> successEmailIds;
  final bool isThread;

  MarkAsStarMultipleEmailHasSomeEmailFailure(
    this.countMarkStarSuccess,
    this.markStarAction,
    this.successEmailIds, {
    this.isThread = false,
  });

  @override
  List<Object?> get props => [
        countMarkStarSuccess,
        markStarAction,
        successEmailIds,
        isThread,
      ];
}

class MarkAsStarMultipleEmailFailure extends FeatureFailure {
  final MarkStarAction markStarAction;

  MarkAsStarMultipleEmailFailure(
    this.markStarAction,
    dynamic exception,
  ) : super(exception: exception);

  @override
  List<Object?> get props => [markStarAction, exception];
}
