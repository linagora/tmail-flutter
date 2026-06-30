import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:workplace/domain/entity/drive_document.dart';

sealed class DrivePickState extends Equatable {}

final class DrivePickResult extends DrivePickState {
  final List<DriveDocument> documents;
  DrivePickResult(this.documents);
  
  @override
  List<Object> get props => [documents];
}

final class DrivePickFailure extends DrivePickState implements FeatureFailure {
  final Object error;
  final String? message;
  DrivePickFailure(this.error, {this.message});
  
  @override
  List<Object?> get props => [error, message];

  @override
  get exception => error;

  @override
  Stream<Either<Failure, Success>>? get onRetry => null;
}
