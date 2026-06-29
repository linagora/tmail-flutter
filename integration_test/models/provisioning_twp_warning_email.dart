import 'package:model/model.dart';

/// Request describing an Inbox email to provision with a backend-positioned
/// `X-TWP-Message` warning header. A value object so callers pass one typed
/// argument instead of several loose strings.
class ProvisioningTwpWarningEmail {
  final String subject;
  final String message;
  final TwpWarningLevel level;
  final String? code;

  const ProvisioningTwpWarningEmail({
    required this.subject,
    required this.message,
    this.level = TwpWarningLevel.warn,
    this.code,
  });

  /// The raw `X-TWP-Message` header value: `level:<level> [code:<code>] <message>`.
  String get headerValue => [
    'level:${level.name}',
    if (code != null) 'code:$code',
    message,
  ].join(' ');
}
