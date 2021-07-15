import 'package:core/core.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

@immutable
class MailboxState extends AppState {
  MailboxState(Either<Failure, Success> viewState) : super(viewState);
}

@immutable
class MailboxStateLoadingAction extends ViewState {
  @override
  List<Object?> get props => [];
}

@immutable
class MailboxStateInitAction extends ViewState {
  @override
  List<Object?> get props => [];
}