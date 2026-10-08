@TestOn('chrome')
@Tags(['mutation'])
library;

import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/dom/add_lazy_loading_for_background_image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/responsive_table_cell_transformer.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/html_emails/html_email_corpus_fixture.dart';
import '../display_harness/display_case.dart';
import 'content_preservation.dart';
import 'expect_checkers.dart';
import 'generic_rules.dart';

/// Proof that every display rule bites: each test breaks one mechanism in
/// the test (never in production code) and expects at least one case to show
/// a violation it does not show unbroken. The matrix is red on purpose in
/// places (recorded findings), so a violation only counts when it is new.
///
/// Local: `fvm flutter test --platform chrome -t mutation --run-skipped
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

typedef _Check = Future<List<Violation>> Function(DisplayRender render);

class _Found {
  const _Found(this.displayCase, this.violation);

  final DisplayCase displayCase;
  final Violation violation;

  String get describe => violation.describe(displayCase);
}

class _Mutation {
  const _Mutation({
    required this.name,
    required this.mutation,
    required this.check,
    required this.cases,
  });

  final String name;
  final DisplayMutation mutation;
  final _Check check;
  final Iterable<DisplayCase> Function() cases;

  Future<Set<String>> _violations(DisplayCase displayCase, DisplayMutation? mutation) async {
    final render = await renderDisplayCase(displayCase, mutation: mutation);
    try {
      return {for (final v in await check(render)) _key(v)};
    } finally {
      render.dispose();
    }
  }

  /// The first case (in [cases] order) where the mutation adds a violation.
  Future<_Found?> firstNewViolation() async {
    for (final displayCase in cases()) {
      final unbroken = await _violations(displayCase, null);
      final render = await renderDisplayCase(displayCase, mutation: mutation);
      try {
        for (final violation in await check(render)) {
          if (!unbroken.contains(_key(violation))) return _Found(displayCase, violation);
        }
      } finally {
        render.dispose();
      }
    }
    return null;
  }
}

/// A violation is new when its rule and element are new: an element that
/// already overflows does not count again because its size changed.
String _key(Violation violation) => '${violation.rule}|${violation.path}';

/// [replacement] applied once to [document]; fails loudly when the target is
/// gone, so a refactor cannot silently turn a mutation into a no-op.
String _replaceOnce(String document, Pattern target, String replacement, String what) {
  final match = target.allMatches(document).firstOrNull;
  if (match == null) throw StateError('mutation target not found: $what');
  return document.replaceRange(match.start, match.end, replacement);
}

/// Removes the `<script>` block that contains [marker].
String _removeScript(String document, String marker) {
  final at = document.indexOf(marker);
  if (at < 0) throw StateError('mutation target not found: script with "$marker"');
  final start = document.lastIndexOf('<script', at);
  final end = document.indexOf('</script>', at) + '</script>'.length;
  return document.replaceRange(start, end, '');
}

TransformConfiguration _without(DisplayViewer viewer, List<Type> removed) {
  final config = viewer.transformConfiguration();
  return TransformConfiguration(
    [
      for (final transformer in config.domTransformers)
        if (!removed.contains(transformer.runtimeType)) transformer,
    ],
    config.textTransformers,
  );
}

/// A sanitizer regression that loses every table.
class _DropTablesTransformer extends TextTransformer {
  const _DropTablesTransformer();

  @override
  String process(String text, HtmlEscape htmlEscape) =>
      text.replaceAll(RegExp(r'<table[\s\S]*?</table>', caseSensitive: false), '');
}

Iterable<DisplayCase> _casesWhere(
  bool Function(HtmlEmailCorpusFixture fixture) keep, {
  required List<DisplayViewer> viewers,
  bool Function(int width)? width,
}) sync* {
  for (final displayCase in displayCases(viewers: viewers)) {
    if (!keep(displayCase.fixture)) continue;
    if (width != null && !width(displayCase.width)) continue;
    yield displayCase;
  }
}

bool _has(HtmlEmailCorpusFixture fixture, String tag) =>
    !fixture.isPlainText && fixture.html.contains('<$tag');

bool _expects(HtmlEmailCorpusFixture fixture, HtmlEmailExpect label) =>
    fixture.expect.contains(label);

Future<List<Violation>> _overflow(DisplayRender render) async => overflowRule(render);

Future<List<Violation>> _preservation(DisplayRender render) async {
  final fixture = render.displayCase.fixture;
  if (fixture.allowEmptyBody) return const [];
  final kept = bodyWordPreservation(fixture.html, render.transformedHtml);
  return [
    if (kept < fixture.minPreservation)
      Violation('G-preserve', '.tmail-content', '${(kept * 100).toStringAsFixed(1)}% of the words kept'),
    if (bodyLinkCount(render.transformedHtml) != bodyKeptLinkCount(fixture.html))
      const Violation('G-preserve', 'a[href]', 'link count changed'),
  ];
}

final _mutations = <_Mutation>[
  _Mutation(
    name: 'remove ResponsiveTableCellTransformer',
    mutation: DisplayMutation(
      transformConfiguration: (viewer) => _without(viewer, [ResponsiveTableCellTransformer]),
    ),
    check: _overflow,
    cases: () => _casesWhere((f) => _has(f, 'td'), viewers: [DisplayViewer.web, DisplayViewer.ios]),
  ),
  _Mutation(
    name: 'remove ResponsiveTableCellTransformer (real emails only)',
    mutation: DisplayMutation(
      transformConfiguration: (viewer) => _without(viewer, [ResponsiveTableCellTransformer]),
    ),
    check: _overflow,
    cases: () => _casesWhere((f) => f.category == 'real' && _has(f, 'td'),
        viewers: [DisplayViewer.web, DisplayViewer.ios, DisplayViewer.native]),
  ),
  _Mutation(
    name: 'remove the @media (max-width: 600px) table { width: 100% } rule',
    mutation: DisplayMutation(
      document: (document) => _replaceOnce(
        document,
        RegExp(r'table\s*\{\s*width:\s*100%\s*!important;\s*\}'),
        '',
        '@media table width rule',
      ),
    ),
    check: _overflow,
    cases: () => _casesWhere((f) => _has(f, 'table'), viewers: DisplayViewer.values,
        width: (w) => w <= 600),
  ),
  _Mutation(
    name: 'remove generateNormalizeImageScript',
    mutation: DisplayMutation(
      document: (document) => _removeScript(document, 'const displayWidth'),
    ),
    check: (render) async => [...imageFitRule(render), ...overflowRule(render)],
    cases: () => _casesWhere((f) => _has(f, 'img'), viewers: [DisplayViewer.web, DisplayViewer.native]),
  ),
  _Mutation(
    name: 'disable the mobile responsive script',
    mutation: DisplayMutation(
      document: (document) => _removeScript(document, 'function scheduleResponsiveLayout'),
    ),
    check: autoScaleChecker,
    cases: () => _casesWhere((f) => _expects(f, HtmlEmailExpect.autoScale),
        viewers: [DisplayViewer.native]),
  ),
  _Mutation(
    name: 'lower the reflow font floor from 12px to 8px',
    mutation: DisplayMutation(
      document: (document) => _replaceOnce(
        document,
        'Math.max(12, textElement.fontSize * textScale)',
        'Math.max(8, textElement.fontSize * textScale)',
        'reflow font floor',
      ),
    ),
    check: autoScaleChecker,
    cases: () => _casesWhere((f) => _expects(f, HtmlEmailExpect.autoScale),
        viewers: [DisplayViewer.native], width: (w) => w <= 480),
  ),
  _Mutation(
    name: 'remove ImageTransformer and AddLazyLoadingForBackgroundImageTransformer',
    mutation: DisplayMutation(
      transformConfiguration: (viewer) => _without(
        viewer,
        [ImageTransformer, AddLazyLoadingForBackgroundImageTransformer],
      ),
    ),
    check: lazyImagesChecker,
    cases: () => _casesWhere((f) => _expects(f, HtmlEmailExpect.lazyImages),
        viewers: [DisplayViewer.native, DisplayViewer.web]),
  ),
  _Mutation(
    name: 'disable the quote toggle',
    mutation: const DisplayMutation(quoteToggle: false),
    check: quoteToggleChecker,
    cases: () => _casesWhere((f) => _expects(f, HtmlEmailExpect.quoteToggle),
        viewers: [DisplayViewer.native, DisplayViewer.web]),
  ),
  _Mutation(
    name: 'sanitizer drops <table>',
    mutation: DisplayMutation(
      transformConfiguration: (viewer) {
        final config = viewer.transformConfiguration();
        return TransformConfiguration(
          config.domTransformers,
          [...config.textTransformers, const _DropTablesTransformer()],
        );
      },
    ),
    check: _preservation,
    cases: () => _casesWhere((f) => _has(f, 'table'), viewers: [DisplayViewer.native],
        width: (w) => w == 390),
  ),
];
