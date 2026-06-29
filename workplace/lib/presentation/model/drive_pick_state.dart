import 'package:equatable/equatable.dart';
import 'package:workplace/domain/entity/drive_document.dart';

sealed class DrivePickState extends Equatable {}

final class DrivePickResult extends DrivePickState {
  final List<DriveDocument> documents;
  DrivePickResult(this.documents);
  
  @override
  List<Object> get props => [documents];
}

final class DrivePickFailure extends DrivePickState {
  final Object error;
  DrivePickFailure(this.error);
  
  @override
  List<Object?> get props => [error];
}
