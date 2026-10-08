import 'package:core/presentation/utils/html_transformer/dom/hide_draft_signature_transformer.dart';
import 'package:core/presentation/utils/html_transformer/dom/image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/script_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';

import 'html_pipeline_registry.dart';

void main() {
  tearDown(() {
    PlatformInfo.isTestingForWeb = false;
  });

  test('covers every named TransformConfiguration pipeline', () {
    final fromSource = htmlPipelineFactoryNamesFromSource(
      htmlPipelineTransformConfigurationSource(),
    );
    final fromRegistry =
        htmlPipelineRegistry().map((row) => row.factoryName).toSet();

    expect(
      fromRegistry,
      fromSource,
      reason: 'a new pipeline needs a row in htmlPipelineRegistry()',
    );
  });

  group('TransformConfiguration contract — sanitizer vs input trust', () {
    for (final row in htmlPipelineRegistry()) {
      test('${row.name} ${row.trust.name} trust', () {
        final config = row.build();
        switch (row.trust) {
          case HtmlPipelineTrust.raw:
            expect(
              pipelineHasSanitizer(config, input: row.input),
              isTrue,
              reason: '${row.name} receives raw HTML and must sanitize',
            );
          case HtmlPipelineTrust.sanitized:
            expect(
              pipelineHasSanitizer(config, input: row.input),
              isFalse,
              reason:
                  '${row.name} receives already-sanitized EmailLoaded; '
                  'see html_loaded_provenance_test.dart',
            );
          case HtmlPipelineTrust.user:
            expect(
              pipelineHasSanitizer(config, input: row.input),
              row.wiring == HtmlPipelineWiring.sanitizes,
              reason: '${row.name} user-authored policy is ${row.wiring.name}',
            );
        }
      }, skip: row.knownGap);
    }
  });

  group('TransformConfiguration contract — current membership', () {
    test('preview configs currently allow contenteditable', () {
      expect(
        pipelineAllowsContentEditable(TransformConfiguration.forPreviewEmail()),
        isTrue,
      );
      expect(
        pipelineAllowsContentEditable(
          TransformConfiguration.forPreviewEmailOnWeb(),
        ),
        isTrue,
      );
      expect(
        pipelineAllowsContentEditable(
          TransformConfiguration.forEditDraftsEmail(),
        ),
        isTrue,
      );
    });

    test('attachment preview sanitizes and does not rewrite display layout', () {
      final config = TransformConfiguration.forAttachmentPreview();
      expect(pipelineHasSanitizer(config), isTrue);
      expect(pipelineHasDisplayOnly(config), isFalse);
      expect(
        config.domTransformers.any((transformer) => transformer is ImageTransformer),
        isFalse,
      );
    });

    test('send/edit configs omit table/float/lazy display transformers', () {
      for (final config in [
        TransformConfiguration.forReplyForwardEmail(),
        TransformConfiguration.forReplyForwardEmptyEmail(),
        TransformConfiguration.forDraftsEmail(),
        TransformConfiguration.forEditDraftsEmail(),
        TransformConfiguration.forComposerSignature(),
        TransformConfiguration.forPrintEmail(),
      ]) {
        expect(pipelineHasDisplayOnly(config), isFalse);
      }
    });

    test('print has no sanitizer (input is already-sanitized EmailLoaded)', () {
      expect(pipelineHasSanitizer(TransformConfiguration.forPrintEmail()), isFalse);
    });

    test('reply-forward has no sanitizer (input is EmailLoaded.htmlContent)', () {
      expect(
        pipelineHasSanitizer(TransformConfiguration.forReplyForwardEmail()),
        isFalse,
      );
    });

    test('forRemoveScript is present on full preview configs', () {
      expect(
        TransformConfiguration.forPreviewEmailOnWeb().domTransformers.any(
          (transformer) => transformer is RemoveScriptTransformer,
        ),
        isTrue,
      );
      expect(
        TransformConfiguration.standardConfiguration.domTransformers.any(
          (transformer) => transformer is RemoveScriptTransformer,
        ),
        isTrue,
      );
    });

    test('HideDraftSignatureTransformer is web-only on edit drafts', () {
      PlatformInfo.isTestingForWeb = false;
      expect(
        TransformConfiguration.forEditDraftsEmail().domTransformers.any(
          (transformer) => transformer is HideDraftSignatureTransformer,
        ),
        isFalse,
      );

      PlatformInfo.isTestingForWeb = true;
      expect(
        TransformConfiguration.forEditDraftsEmail().domTransformers.any(
          (transformer) => transformer is HideDraftSignatureTransformer,
        ),
        isTrue,
      );
    });

    test('forPreviewEmailOnPlatform matches mobile and web preview', () {
      PlatformInfo.isTestingForWeb = false;
      expect(
        pipelineHasSanitizer(TransformConfiguration.forPreviewEmailOnPlatform()),
        isTrue,
      );

      PlatformInfo.isTestingForWeb = true;
      expect(
        pipelineHasSanitizer(TransformConfiguration.forPreviewEmailOnPlatform()),
        isTrue,
      );
    });
  });
}
