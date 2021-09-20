import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';

class MarkAsStarEmailSuccess extends UIState {
  final Email updatedEmail;
  final MarkStarAction markStarAction;

  MarkAsStarEmailSuccess(this.updatedEmail, this.markStarAction);

  @override
  List<Object?> get props => [updatedEmail, markStarAction];
}

class MarkAsStarEmailFailure extends FeatureFailure {
  final exception;
  final MarkStarAction markStarAction;

  MarkAsStarEmailFailure(this.exception, this.markStarAction);

  @override
  List<Object> get props => [exception, markStarAction];
}