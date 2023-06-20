import 'package:core/core.dart';

class StoreNewEmailLoading extends UIState {}

class StoreNewEmailSuccess extends UIState {}

class StoreNewEmailFailure extends FeatureFailure {

  StoreNewEmailFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}