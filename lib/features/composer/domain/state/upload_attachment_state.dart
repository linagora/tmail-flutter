import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:model/model.dart';

class UploadAttachmentLoadingState extends UIState {
  UploadAttachmentLoadingState();

  @override
  List<Object?> get props => [];
}

class UploadAttachmentSuccess extends UIState {
  final Attachment attachment;

  UploadAttachmentSuccess(this.attachment);

  @override
  List<Object?> get props => [attachment];
}

class UploadAttachmentFailure extends FeatureFailure {
  final exception;

  UploadAttachmentFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class UploadAttachmentAllSuccess extends UIState {
  final List<Either<Failure, Success>> listResults;

  UploadAttachmentAllSuccess(this.listResults);

  @override
  List<Object?> get props => [listResults];
}

class UploadAttachmentHasSomeFailure extends UIState {
  final List<Either<Failure, Success>> listResults;

  UploadAttachmentHasSomeFailure(this.listResults);

  @override
  List<Object?> get props => [listResults];
}

class UploadAttachmentAllFailure extends FeatureFailure {
  final exception;

  UploadAttachmentAllFailure(this.exception);

  @override
  List<Object> get props => [exception];
}