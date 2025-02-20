import 'dart:typed_data';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/attachment.dart';

class GettingTextDataFromAttachment extends LoadingState {
  GettingTextDataFromAttachment({required this.attachment});

  final Attachment attachment;

  @override
  List<Object> get props => [attachment];
}

class GetTextDataFromAttachmentSuccess extends UIState {
  GetTextDataFromAttachmentSuccess({
    required this.attachment,
    required this.data,
  });

  final Attachment attachment;
  final Uint8List data;

  @override
  List<Object> get props => [attachment, data];
}

class GetTextDataFromAttachmentFailure extends FeatureFailure {
  GetTextDataFromAttachmentFailure({super.exception});
}