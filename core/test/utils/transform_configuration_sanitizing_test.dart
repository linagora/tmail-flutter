import 'package:core/presentation/utils/html_transformer/dom/script_transformers.dart';
import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every configuration whose output is rendered in an iframe, a WebView, a
/// same-origin tab or the composer editor must sanitize its input: email
/// content is attacker-controlled.
///
/// forComposerSignature is deliberately absent: it only processes the
/// user's own identity signature, which was sanitized when saved
/// (forSignatureIdentity) and must be sent unmodified.
void main() {
  final configurations = <String, TransformConfiguration Function()>{
    'standardConfiguration': () => TransformConfiguration.standardConfiguration,
    'forPreviewEmailOnWeb': TransformConfiguration.forPreviewEmailOnWeb,
    'forPreviewEmail': TransformConfiguration.forPreviewEmail,
    'forRestoreEmail': TransformConfiguration.forRestoreEmail,
    'forDraftsEmail': TransformConfiguration.forDraftsEmail,
    'forEditDraftsEmail': TransformConfiguration.forEditDraftsEmail,
    'forReplyForwardEmail': TransformConfiguration.forReplyForwardEmail,
    'forReplyForwardEmptyEmail': TransformConfiguration.forReplyForwardEmptyEmail,
    'forPrintEmail': TransformConfiguration.forPrintEmail,
    'forSignatureIdentity': TransformConfiguration.forSignatureIdentity,
    'forCalendarEvent': TransformConfiguration.forCalendarEvent,
  };

  group('TransformConfiguration — sanitizer is always applied', () {
    configurations.forEach((name, create) {
      test('$name SHOULD include StandardizeHtmlSanitizingTransformers', () {
        expect(
          create().textTransformers
              .whereType<StandardizeHtmlSanitizingTransformers>(),
          isNotEmpty,
        );
      });
    });

    for (final name in const [
      'forReplyForwardEmail',
      'forReplyForwardEmptyEmail',
      'forPrintEmail',
    ]) {
      test('$name SHOULD include RemoveScriptTransformer', () {
        expect(
          configurations[name]!().domTransformers
              .whereType<RemoveScriptTransformer>(),
          isNotEmpty,
        );
      });
    }
  });
}
