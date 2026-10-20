@TestOn('chrome')
@Tags(['mutation'])
library;

import 'package:core/presentation/utils/html_transformer/dom/remove_lazy_loading_for_background_image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/remove_lazy_loading_image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/html_emails/html_email_corpus_fixture.dart';
import '../display_harness/display_case.dart';
import 'generic_rules.dart';
import 'mutation_proof.dart';
import 'surface_rules.dart';

/// Proof that every surface rule bites: each test breaks one mechanism in
/// the test (never in production code) and expects at least one case to show
/// a violation it does not show unbroken. A violation only counts when new.
///
/// Local: `flutter test --platform chrome -t mutation --run-skipped
/// test/utils/html/display_rules/surface_mutation_proof_browser_test.dart`.
void main() {
  for (final mutation in _mutations) {
    test(mutation.name, () async {
      final found = await mutation.firstNewViolation();
      expect(
        found,
        isNotNull,
        reason: 'mutation "${mutation.name}" turned no fixture red',
      );
    }, timeout: const Timeout(Duration(minutes: 5)));
  }
}

final _mutations = <DisplayMutationProof>[
  DisplayMutationProof(
    name: 'drafts: images fit',
    // The native document also fits images through its responsive script.
    mutation: DisplayMutation(
      document: (d) => removeScript(
        removeScript(d, 'const displayWidth'),
        'function scheduleResponsiveLayout',
      ),
    ),
    check: (render) async => [...imageFitRule(render), ...overflowRule(render)],
    cases: () => casesWhere((f) => hasTag(f, 'img'), viewers: [DisplayViewer.drafts]),
  ),
  DisplayMutationProof(
    name: 'attachment: images fit',
    mutation: DisplayMutation(
      document: (d) => removeScript(d, 'const displayWidth'),
    ),
    check: (render) async => [...imageFitRule(render), ...overflowRule(render)],
    cases: () => casesWhere((f) => hasTag(f, 'img'), viewers: [DisplayViewer.attachment]),
  ),
  DisplayMutationProof(
    name: 'calendar: images fit',
    mutation: DisplayMutation(
      document: (d) => removeScript(d, 'const displayWidth'),
    ),
    check: (render) async => [...imageFitRule(render), ...overflowRule(render)],
    cases: () => casesWhere((f) => hasTag(f, 'img'), viewers: [DisplayViewer.calendarNative]),
  ),
  DisplayMutationProof(
    name: 'signature: no overflow',
    mutation: DisplayMutation(
      document: (d) => replaceOnce(
        d,
        '<div class="tmail-content">',
        '<div class="tmail-content"><div style="width:900px">wide</div>',
        'signature content div',
      ),
    ),
    check: overflowCheck,
    cases: () => casesWhere((_) => true,
        viewers: [DisplayViewer.signatureWeb, DisplayViewer.signatureNative]),
  ),
  DisplayMutationProof(
    name: 'print: no lazy loading left',
    mutation: DisplayMutation(
      transformConfiguration: (_) => withoutDomTransformers(
        TransformConfiguration.forPrintEmail(),
        [RemoveLazyLoadingImageTransformer, RemoveLazyLoadingForBackgroundImageTransformer],
      ),
    ),
    check: (render) async => printLazyRule(render),
    cases: () => casesWhere((f) => expects(f, HtmlEmailExpect.lazyImages),
        viewers: [DisplayViewer.print]),
  ),
];
