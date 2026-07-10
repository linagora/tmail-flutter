import 'package:equatable/equatable.dart';
import 'package:workplace/domain/entity/drive_document.dart';

/// Result the Drive picker dialog is popped with.
sealed class DrivePickOutcome extends Equatable {
  const DrivePickOutcome();
}

final class DrivePickOutcomePicked extends DrivePickOutcome {
  final List<DriveDocument> documents;
  const DrivePickOutcomePicked(this.documents);

  @override
  List<Object> get props => [documents];
}

final class DrivePickOutcomeCancelled extends DrivePickOutcome {
  const DrivePickOutcomeCancelled();

  @override
  List<Object> get props => [];
}

final class DrivePickOutcomeFailed extends DrivePickOutcome {
  final Object error;
  const DrivePickOutcomeFailed(this.error);

  @override
  List<Object> get props => [error];
}
