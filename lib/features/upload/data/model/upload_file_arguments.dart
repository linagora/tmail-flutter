
import 'package:core/data/network/dio_client.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:tmail_ui_user/features/upload/domain/model/mobile_file_upload.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';

class UploadFileArguments with EquatableMixin {

  final DioClient dioClient;
  final UploadTaskId uploadId;
  final MobileFileUpload mobileFileUpload;
  final Uri uploadUri;
  final RootIsolateToken isolateToken;

  UploadFileArguments(
    this.dioClient,
    this.uploadId,
    this.mobileFileUpload,
    this.uploadUri,
    this.isolateToken,
  );

  @override
  List<Object?> get props => [
    dioClient,
    uploadId,
    mobileFileUpload,
    uploadUri,
    isolateToken,
  ];
}