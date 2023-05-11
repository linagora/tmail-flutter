import 'package:core/core.dart';

class StoreOpenedEmailToCacheLoading extends UIState {}

class StoreOpenedEmailToCacheSuccess extends UIState {}

class StoreOpenedEmailToCacheFailure extends FeatureFailure {

  StoreOpenedEmailToCacheFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}