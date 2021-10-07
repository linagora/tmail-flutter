import 'package:equatable/equatable.dart';

abstract class Success with EquatableMixin {}

abstract class ViewState extends Success {}

class UIState extends ViewState {
  static final idle = UIState();

  UIState() : super();

  @override
  List<Object?> get props => [];
}

class LoadingState extends UIState {
  LoadingState();

  @override
  List<Object?> get props => [];
}

class LoadingMoreState extends UIState {
  LoadingMoreState();

  @override
  List<Object?> get props => [];
}

class RefreshingState extends UIState {
  RefreshingState();

  @override
  List<Object?> get props => [];
}