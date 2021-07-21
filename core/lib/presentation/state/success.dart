import 'package:equatable/equatable.dart';

abstract class Success with EquatableMixin {}

abstract class ViewState extends Success {}

class UIState extends ViewState {
  static final idle = UIState();
  static final loading = UIState();

  UIState() : super();

  @override
  List<Object?> get props => [];
}
