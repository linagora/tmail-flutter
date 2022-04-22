import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:model/model.dart';

class RefreshChangesAllEmailSuccess extends UIState {
  final List<PresentationEmail> emailList;
  final State? currentEmailState;

  RefreshChangesAllEmailSuccess({required this.emailList, this.currentEmailState});

  @override
  List<Object?> get props => [emailList, currentEmailState];
}

class RefreshChangesAllEmailFailure extends FeatureFailure {
  final dynamic exception;

  RefreshChangesAllEmailFailure(this.exception);

  @override
  List<Object> get props => [exception];
}