
import 'package:core/data/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';

class UploadFileArguments with EquatableMixin {

  final DioClient dioClient;
  final UploadTaskId uploadId;
  final FileInfo fileInfo;
  final Uri uploadUri;
  final CancelToken? cancelToken;

  UploadFileArguments(
    this.dioClient,
    this.uploadId,
    this.fileInfo,
    this.uploadUri,
    {this.cancelToken});

  @override
  List<Object?> get props => [uploadId, fileInfo, uploadUri];
}