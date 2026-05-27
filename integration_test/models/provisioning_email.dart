import 'package:labels/labels.dart';
import 'package:model/upload/file_info.dart';

class ProvisioningEmail {
  final String toEmail;
  final String subject;
  final String content;
  final List<String> attachmentPaths;
  final List<FileInfo> fileInfos;
  final List<Label> labels;

  ProvisioningEmail({
    required this.toEmail,
    required this.subject,
    required this.content,
    this.attachmentPaths = const [],
    this.fileInfos = const [],
    this.labels = const [],
  });
}