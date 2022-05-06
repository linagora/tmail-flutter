import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

@immutable
class LoginState extends AppState {
  LoginState(Either<Failure, Success> viewState) : super(viewState);
}

@immutable
class InputUrlCompletion extends ViewState {
  @override
  List<Object?> get props => [];
}

@immutable
class LoginLoadingAction extends ViewState {
  @override
  List<Object?> get props => [];
}

@immutable
class LoginInitAction extends ViewState {
  @override
  List<Object?> get props => [];
}

@immutable
class LoginMissUrlAction extends Failure {
  @override
  List<Object?> get props => [];
}

@immutable
class LoginMissUsernameAction extends Failure {
  @override
  List<Object?> get props => [];
}

@immutable
class LoginMissPasswordAction extends Failure {
  @override
  List<Object?> get props => [];
}