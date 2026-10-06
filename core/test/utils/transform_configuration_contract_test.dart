import 'package:core/presentation/utils/html_transformer/dom/add_lazy_loading_for_background_image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/hide_draft_signature_transformer.dart';
import 'package:core/presentation/utils/html_transformer/dom/image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/remove_negative_margin_float_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/responsive_table_cell_transformer.dart';
import 'package:core/presentation/utils/html_transformer/dom/script_transformers.dart';
import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';

enum _InputTrust { raw, sanitized, user }

class _Row {
  const _Row({
    required this.name,
    required this.config,
    required this.trust,
  });

  final String name;
  final TransformConfiguration config;
  final _InputTrust trust;
}

const emptyReplySanitizerSkip =
    'https://github.com/linagora/tmail-flutter/issues/4956: '
    'forReplyForwardEmptyEmail lacks sanitizer';

bool _hasSanitizer(TransformConfiguration config) => config.textTransformers
    .any((transformer) => transformer is StandardizeHtmlSanitizingTransformers);

bool _allowsContentEditable(TransformConfiguration config) => config
    .textTransformers
    .whereType<StandardizeHtmlSanitizingTransformers>()
    .any(
      (transformer) =>
          transformer.allowAttributes?.contains('contenteditable') == true,
    );

bool _hasRemoveScript(TransformConfiguration config) => config.domTransformers
    .any((transformer) => transformer is RemoveScriptTransformer);

bool _hasDisplayOnly(TransformConfiguration config) =>
    config.domTransformers.any(
      (transformer) =>
          transformer is ResponsiveTableCellTransformer ||
          transformer is RemoveNegativeMarginFloatTransformer ||
          transformer is AddLazyLoadingForBackgroundImageTransformer,
    );

bool _hasImage(TransformConfiguration config) => config.domTransformers
    .any((transformer) => transformer is ImageTransformer);

void main() {
  tearDown(() {
    PlatformInfo.isTestingForWeb = false;
  });

  TransformConfiguration editDrafts({required bool web}) {
    PlatformInfo.isTestingForWeb = web;
    return TransformConfiguration.forEditDraftsEmail();
  }

  List<_Row> rows() => [
        _Row(
          name: 'forReplyForwardEmail',
          config: TransformConfiguration.forReplyForwardEmail(),
          trust: _InputTrust.sanitized,
        ),
        _Row(
          name: 'forReplyForwardEmptyEmail',
          config: TransformConfiguration.forReplyForwardEmptyEmail(),
          trust: _InputTrust.raw,
        ),
        _Row(
          name: 'forDraftsEmail',
          config: TransformConfiguration.forDraftsEmail(),
          trust: _InputTrust.raw,
        ),
        _Row(
          name: 'forEditDraftsEmail-vm',
          config: editDrafts(web: false),
          trust: _InputTrust.raw,
        ),
        _Row(
          name: 'forEditDraftsEmail-web',
          config: editDrafts(web: true),
          trust: _InputTrust.raw,
        ),
        _Row(
          name: 'forPreviewEmailOnWeb',
          config: TransformConfiguration.forPreviewEmailOnWeb(),
          trust: _InputTrust.raw,
        ),
        _Row(
          name: 'forPreviewEmail',
          config: TransformConfiguration.forPreviewEmail(),
          trust: _InputTrust.raw,
        ),
        _Row(
          name: 'forPreviewEmailOnPlatform-vm',
          config: TransformConfiguration.forPreviewEmailOnPlatform(),
          trust: _InputTrust.raw,
        ),
        _Row(
          name: 'forRestoreEmail',
          config: TransformConfiguration.forRestoreEmail(),
          trust: _InputTrust.raw,
        ),
        _Row(
          name: 'forPrintEmail',
          config: TransformConfiguration.forPrintEmail(),
          trust: _InputTrust.sanitized,
        ),
        _Row(
          name: 'forSignatureIdentity',
          config: TransformConfiguration.forSignatureIdentity(),
          trust: _InputTrust.user,
        ),
        _Row(
          name: 'forComposerSignature',
          config: TransformConfiguration.forComposerSignature(),
          trust: _InputTrust.user,
        ),
        _Row(
          name: 'forCalendarEvent',
          config: TransformConfiguration.forCalendarEvent(),
          trust: _InputTrust.raw,
        ),
        _Row(
          name: 'standardConfiguration',
          config: TransformConfiguration.standardConfiguration,
          trust: _InputTrust.raw,
        ),
        _Row(
          name: 'forAttachmentPreview',
          config: TransformConfiguration.forAttachmentPreview(),
          trust: _InputTrust.raw,
        ),
      ];

  group('TransformConfiguration contract — sanitizer vs input trust', () {
    for (final row in rows()) {
      final skip = row.name == 'forReplyForwardEmptyEmail'
          ? emptyReplySanitizerSkip
          : null;

      test(
        '${row.name} raw input has sanitizer',
        () {
          if (row.trust == _InputTrust.raw) {
            expect(
              _hasSanitizer(row.config),
              isTrue,
              reason: '${row.name} receives raw HTML and must sanitize',
            );
          }
        },
        skip: skip,
      );
    }
  });

  group('TransformConfiguration contract — current membership', () {
    test('preview configs currently allow contenteditable', () {
      expect(
        _allowsContentEditable(TransformConfiguration.forPreviewEmail()),
        isTrue,
      );
      expect(
        _allowsContentEditable(TransformConfiguration.forPreviewEmailOnWeb()),
        isTrue,
      );
      expect(
        _allowsContentEditable(TransformConfiguration.forEditDraftsEmail()),
        isTrue,
      );
    });

    test('attachment preview sanitizes and does not rewrite display layout', () {
      final config = TransformConfiguration.forAttachmentPreview();
      expect(_hasSanitizer(config), isTrue);
      expect(_hasDisplayOnly(config), isFalse);
      expect(_hasImage(config), isFalse);
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
        expect(_hasDisplayOnly(config), isFalse);
      }
    });

    test('print has no sanitizer (input is already-sanitized EmailLoaded)', () {
      expect(_hasSanitizer(TransformConfiguration.forPrintEmail()), isFalse);
    });

    test('reply-forward has no sanitizer (input is EmailLoaded.htmlContent)', () {
      expect(
        _hasSanitizer(TransformConfiguration.forReplyForwardEmail()),
        isFalse,
      );
    });

    test('forRemoveScript is present on full preview configs', () {
      expect(
        _hasRemoveScript(TransformConfiguration.forPreviewEmailOnWeb()),
        isTrue,
      );
      expect(
        _hasRemoveScript(TransformConfiguration.standardConfiguration),
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

    test('forPreviewEmailOnPlatform sanitizes on VM and web', () {
      PlatformInfo.isTestingForWeb = false;
      expect(
        _hasSanitizer(TransformConfiguration.forPreviewEmailOnPlatform()),
        isTrue,
      );

      PlatformInfo.isTestingForWeb = true;
      expect(
        _hasSanitizer(TransformConfiguration.forPreviewEmailOnPlatform()),
        isTrue,
      );
    });
  });
}
