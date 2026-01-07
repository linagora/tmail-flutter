import 'package:labels/labels.dart';

class ProvisioningEmail {
  final String toEmail;
  final String subject;
  final String content;
  final List<String> attachmentPaths;
  final List<Label> labels;

  ProvisioningEmail({
    required this.toEmail,
    required this.subject,
    required this.content,
    this.attachmentPaths = const [],
    this.labels = const [],
  });
}