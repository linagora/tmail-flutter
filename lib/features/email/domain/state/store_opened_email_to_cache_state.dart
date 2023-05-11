import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreOpenedEmailLoading extends UIState {}

class StoreOpenedEmailSuccess extends UIState {}

class StoreOpenedEmailFailure extends FeatureFailure {

  StoreOpenedEmailFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}