import 'package:core/presentation/utils/html_transformer/dom/hide_draft_signature_transformer.dart';
import 'package:core/presentation/utils/html_transformer/dom/image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/script_transformers.dart';
import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
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

  test('finds a pipeline declared as any factory or static member', () {
    const source = '''
      factory TransformConfiguration.create() => x;
      factory TransformConfiguration.fromDomTransformers(List d) => x;
      factory TransformConfiguration.forPreview() => x;
      factory TransformConfiguration.quotedReply() => x;
      static TransformConfiguration standard = x;
      static final TransformConfiguration finalOne = x;
      static TransformConfiguration get viaGetter => x;
    ''';
    expect(
      htmlPipelineFactoryNamesFromSource(source),
      {'forPreview', 'quotedReply', 'standard', 'finalOne', 'viaGetter'},
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
                  '${row.name} receives EmailLoaded HTML, which '
                  'forPreviewEmailOnPlatform has already sanitized '
                  '(see the pipeline_call_sites lock)',
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

  group('TransformConfiguration contract — contenteditable', () {
    for (final row in htmlPipelineRegistry().where((row) => row.takesHtml)) {
      test('${row.name} ${row.allowsContentEditable ? 'lets' : 'does not let'} '
          'the Drive link card keep contenteditable', () {
        expect(pipelineAllowsContentEditable(row.build()), row.allowsContentEditable);
      });
    }
  });

  group('TransformConfiguration contract — current membership', () {
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
  });

  group('TransformConfiguration contract — rule sets', () {
    test('every pipeline is checked by at least one rule set', () {
      expect(
        rowsWithoutRules(htmlPipelineRegistry()),
        isEmpty,
        reason: 'give the row rules: in htmlPipelineRegistry()',
      );
    });

    test('the guard reports a row with no rule set', () {
      const uncovered = HtmlPipelineRow(
        name: 'probe',
        create: TransformConfiguration.forPreviewEmail,
        trust: HtmlPipelineTrust.raw,
        wiring: HtmlPipelineWiring.sanitizes,
        rules: HtmlPipelineRules(),
      );

      expect(rowsWithoutRules([...htmlPipelineRegistry(), uncovered]), ['probe']);
    });

    test('every display viewer shows exactly one HTML pipeline', () {
      for (final viewer in DisplayViewer.values) {
        final rows = htmlPipelineRegistry()
            .where((row) => row.takesHtml && row.rules.displayOn.contains(viewer));

        expect(rows.length, 1, reason: '${viewer.label}: ${rows.map((r) => r.name)}');
      }
    });

    for (final row in htmlPipelineRegistry().where((row) => row.rules.sameAs != null)) {
      test('${row.name} runs the same transformers as ${row.rules.sameAs}', () {
        final target = htmlPipelineRegistry()
            .singleWhere((other) => other.name == row.rules.sameAs)
            .build();
        final config = row.build();
        List<Type> types(List<Object> list) => [for (final t in list) t.runtimeType];
        Set<String>? allowed(TransformConfiguration c) => c.textTransformers
            .whereType<StandardizeHtmlSanitizingTransformers>()
            .map((t) => t.allowAttributes?.toSet() ?? <String>{})
            .firstOrNull;

        expect(types(config.domTransformers), types(target.domTransformers));
        expect(types(config.textTransformers), types(target.textTransformers));
        expect(allowed(config), allowed(target));
      });
    }
  });
}
