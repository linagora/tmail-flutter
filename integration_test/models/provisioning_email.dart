class ProvisioningEmail {
  final String toEmail;
  final String subject;
  final String content;
  final List<String> attachmentPaths;

  ProvisioningEmail({
    required this.toEmail,
    required this.subject,
    required this.content,
    this.attachmentPaths = const [],
  });
}