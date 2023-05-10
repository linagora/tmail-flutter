import 'package:core/core.dart';

class StoreDetailedEmailToCacheLoading extends UIState {}

class StoreDetailedEmailToCacheSuccess extends UIState {}

class StoreDetailedEmailToCacheFailure extends FeatureFailure {

  StoreDetailedEmailToCacheFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}