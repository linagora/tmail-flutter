import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/mark_star_action.dart';

class LoadingMarkAsStarMultipleEmailAll extends UIState {}

class MarkAsStarMultipleEmailAllSuccess extends UIState {
  final int countMarkStarSuccess;
  final MarkStarAction markStarAction;
  final List<EmailId> emailIds;

  MarkAsStarMultipleEmailAllSuccess(
    this.countMarkStarSuccess,
    this.markStarAction,
    this.emailIds,
  );

  @override
  List<Object?> get props => [countMarkStarSuccess, markStarAction, emailIds];
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

  MarkAsStarMultipleEmailHasSomeEmailFailure(
    this.countMarkStarSuccess,
    this.markStarAction,
    this.successEmailIds,
  );

  @override
  List<Object?> get props => [countMarkStarSuccess, markStarAction, successEmailIds];
}

class MarkAsStarMultipleEmailFailure extends FeatureFailure {
  final MarkStarAction markStarAction;

  MarkAsStarMultipleEmailFailure(this.markStarAction, dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [markStarAction, exception];
}