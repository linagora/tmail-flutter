
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreSendingEmailLoading extends UIState {}

class StoreSendingEmailSuccess extends UIState {}

class StoreSendingEmailFailure extends FeatureFailure {
  StoreSendingEmailFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}