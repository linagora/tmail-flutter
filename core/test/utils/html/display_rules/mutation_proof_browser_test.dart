@TestOn('chrome')
@Tags(['mutation'])
library;

import 'package:core/presentation/utils/html_transformer/dom/add_lazy_loading_for_background_image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/responsive_table_cell_transformer.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/html_emails/html_email_corpus_fixture.dart';
import '../../html_pipeline_registry.dart';
import '../display_harness/display_case.dart';
import 'drop_tables_transformer.dart';
import 'expect_checkers.dart';
import 'generic_rules.dart';
import 'mutation_proof.dart';

/// Proof that every display rule bites: each test breaks one mechanism in
/// the test (never in production code) and expects at least one case to show
/// a violation it does not show unbroken. The matrix is red on purpose in
/// places (recorded findings), so a violation only counts when it is new.
///
/// Local: `flutter test --platform chrome -t mutation --run-skipped
/// test/utils/html/display_rules/mutation_proof_browser_test.dart`.
void main() {
  for (final mutation in _mutations) {
    test(mutation.name, () async {
      final found = await mutation.firstNewViolation();
      expect(
        found,
        isNotNull,
        reason: 'mutation "${mutation.name}" turned no fixture red',
      );
      // ignore: avoid_print
      print('mutation "${mutation.name}" -> ${found!.describe}');
    }, timeout: const Timeout(Duration(minutes: 5)));
  }
}

TransformConfiguration _pipelineOf(DisplayViewer viewer) =>
    displayPipelineFor(viewer, plainText: false)!.build();

final _mutations = <DisplayMutationProof>[
  DisplayMutationProof(
    name: 'remove ResponsiveTableCellTransformer',
    mutation: DisplayMutation(
      transformConfiguration: (viewer) => withoutDomTransformers(_pipelineOf(viewer), [ResponsiveTableCellTransformer]),
    ),
    check: overflowCheck,
    cases: () => casesWhere((f) => hasTag(f, 'td'), viewers: [DisplayViewer.web, DisplayViewer.ios]),
  ),
  DisplayMutationProof(
    name: 'remove the @media (max-width: 600px) table { width: 100% } rule',
    mutation: DisplayMutation(
      document: (document) => replaceOnce(
        document,
        RegExp(r'table\s*\{\s*width:\s*100%\s*!important;\s*\}'),
        '',
      ),
    ),
    check: overflowCheck,
    cases: () => casesWhere((f) => hasTag(f, 'table'), viewers: DisplayViewer.values,
        width: (w) => w <= 600),
  ),
  DisplayMutationProof(
    name: 'remove generateNormalizeImageScript',
    mutation: DisplayMutation(
      document: (document) => removeScript(document, 'const displayWidth'),
    ),
    check: (render) async => [...imageFitRule(render), ...overflowRule(render)],
    cases: () => casesWhere((f) => hasTag(f, 'img'), viewers: [DisplayViewer.web, DisplayViewer.native]),
  ),
  DisplayMutationProof(
    name: 'disable the mobile responsive script',
    mutation: DisplayMutation(
      document: (document) => removeScript(document, 'function scheduleResponsiveLayout'),
    ),
    check: autoScaleChecker,
    cases: () => casesWhere((f) => expects(f, HtmlEmailExpect.autoScale),
        viewers: [DisplayViewer.native]),
  ),
  DisplayMutationProof(
    name: 'lower the reflow font floor from 12px to 8px',
    mutation: DisplayMutation(
      document: (document) => replaceOnce(
        document,
        'Math.max(12, textElement.fontSize * textScale)',
        'Math.max(8, textElement.fontSize * textScale)',
      ),
    ),
    check: autoScaleChecker,
    cases: () => casesWhere((f) => expects(f, HtmlEmailExpect.autoScale),
        viewers: [DisplayViewer.native], width: (w) => w <= 480),
  ),
  DisplayMutationProof(
    name: 'remove ImageTransformer and AddLazyLoadingForBackgroundImageTransformer',
    mutation: DisplayMutation(
      transformConfiguration: (viewer) => withoutDomTransformers(_pipelineOf(viewer), [ImageTransformer, AddLazyLoadingForBackgroundImageTransformer],
      ),
    ),
    check: lazyImagesChecker,
    cases: () => casesWhere((f) => expects(f, HtmlEmailExpect.lazyImages),
        viewers: [DisplayViewer.native, DisplayViewer.web]),
  ),
  DisplayMutationProof(
    name: 'disable the quote toggle',
    mutation: const DisplayMutation(quoteToggle: false),
    check: quoteToggleChecker,
    cases: () => casesWhere((f) => expects(f, HtmlEmailExpect.quoteToggle),
        viewers: [DisplayViewer.native, DisplayViewer.web]),
  ),
  DisplayMutationProof(
    name: 'sanitizer drops <table>',
    mutation: DisplayMutation(
      transformConfiguration: (viewer) {
        final config = _pipelineOf(viewer);
        return TransformConfiguration(
          config.domTransformers,
          [...config.textTransformers, const DropTablesTransformer()],
        );
      },
    ),
    check: preservationCheck,
    cases: () => casesWhere((f) => hasTag(f, 'table'), viewers: [DisplayViewer.native],
        width: (w) => w == 390),
  ),
];
