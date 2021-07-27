import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AppState with EquatableMixin {
  final Either<Failure, Success> viewState;

  AppState(this.viewState);

  @override
  List<Object?> get props => [viewState];
}