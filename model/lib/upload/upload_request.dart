
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/model.dart';

class UploadRequest with EquatableMixin {

  final Uri uploadUrl;
  final FileInfo fileInfo;
  final AccountId accountId;

  UploadRequest(this.uploadUrl, this.accountId, this.fileInfo);

  @override
  List<Object?> get props => [uploadUrl, accountId, fileInfo];
}