import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class AppState with EquatableMixin {
  final Either<Failure, Success> viewState;

  AppState(this.viewState);

  @override
  List<Object?> get props => [viewState];
}