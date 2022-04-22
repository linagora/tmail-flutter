import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:model/model.dart';

class UploadingAttachmentState extends UIState {
  UploadingAttachmentState();

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
  final dynamic exception;

  UploadAttachmentFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class UploadMultipleAttachmentAllSuccess extends UIState {
  final List<Either<Failure, Success>> listResults;

  UploadMultipleAttachmentAllSuccess(this.listResults);

  @override
  List<Object?> get props => [listResults];
}

class UploadMultipleAttachmentHasSomeFailure extends UIState {
  final List<Either<Failure, Success>> listResults;

  UploadMultipleAttachmentHasSomeFailure(this.listResults);

  @override
  List<Object?> get props => [listResults];
}

class UploadMultipleAttachmentAllFailure extends FeatureFailure {
  final List<Either<Failure, Success>> listResults;

  UploadMultipleAttachmentAllFailure(this.listResults);

  @override
  List<Object> get props => [listResults];
}

class UploadMultipleAttachmentFailure extends FeatureFailure {
  final exception;

  UploadMultipleAttachmentFailure(this.exception);

  @override
  List<Object> get props => [exception];
}