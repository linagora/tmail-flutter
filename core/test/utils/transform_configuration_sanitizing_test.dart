import 'package:core/presentation/utils/html_transformer/dom/script_transformers.dart';
import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every configuration whose output is rendered in an iframe, a WebView, a
/// same-origin tab or the composer editor must sanitize its input: email
/// content is attacker-controlled. Content already sanitized for display
/// (reply/forward quoting, print) is not sanitized again.
void main() {
  final configurations = <String, TransformConfiguration Function()>{
    'standardConfiguration': () => TransformConfiguration.standardConfiguration,
    'forPreviewEmailOnWeb': TransformConfiguration.forPreviewEmailOnWeb,
    'forPreviewEmail': TransformConfiguration.forPreviewEmail,
    'forRestoreEmail': TransformConfiguration.forRestoreEmail,
    'forDraftsEmail': TransformConfiguration.forDraftsEmail,
    'forEditDraftsEmail': TransformConfiguration.forEditDraftsEmail,
    'forReplyForwardEmptyEmail': TransformConfiguration.forReplyForwardEmptyEmail,
    'forSignatureIdentity': TransformConfiguration.forSignatureIdentity,
    'forComposerSignature': TransformConfiguration.forComposerSignature,
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

    final quotedOrPrinted = <String, TransformConfiguration Function()>{
      'forReplyForwardEmail': TransformConfiguration.forReplyForwardEmail,
      'forReplyForwardEmptyEmail': TransformConfiguration.forReplyForwardEmptyEmail,
      'forPrintEmail': TransformConfiguration.forPrintEmail,
    };
    quotedOrPrinted.forEach((name, create) {
      test('$name SHOULD include RemoveScriptTransformer', () {
        expect(
          create().domTransformers.whereType<RemoveScriptTransformer>(),
          isNotEmpty,
        );
      });
    });
  });
}
