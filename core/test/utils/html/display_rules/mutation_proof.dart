/// Helpers of the mutation proofs: each proof breaks one mechanism in the
/// test (never in production code) and expects a rule to notice.
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';

import '../../../fixtures/html_emails/html_email_corpus_fixture.dart';
import '../display_harness/display_case.dart';
import 'content_preservation.dart';
import 'generic_rules.dart';

typedef MutationCheck = Future<List<Violation>> Function(DisplayRender render);

class MutationFound {
  const MutationFound(this.displayCase, this.violation);

  final DisplayCase displayCase;
  final Violation violation;

  String get describe => violation.describe(displayCase);
}

class DisplayMutationProof {
  const DisplayMutationProof({
    required this.name,
    required this.mutation,
    required this.check,
    required this.cases,
  });

  final String name;
  final DisplayMutation mutation;
  final MutationCheck check;
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
  Future<MutationFound?> firstNewViolation() async {
    for (final displayCase in cases()) {
      final unbroken = await _violations(displayCase, null);
      final render = await renderDisplayCase(displayCase, mutation: mutation);
      try {
        for (final violation in await check(render)) {
          if (!unbroken.contains(_key(violation))) return MutationFound(displayCase, violation);
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
String replaceOnce(String document, Pattern target, String replacement, String what) {
  final match = target.allMatches(document).firstOrNull;
  if (match == null) throw StateError('mutation target not found: $what');
  return document.replaceRange(match.start, match.end, replacement);
}

/// Removes the `<script>` block that contains [marker].
String removeScript(String document, String marker) {
  final at = document.indexOf(marker);
  if (at < 0) throw StateError('mutation target not found: script with "$marker"');
  final start = document.lastIndexOf('<script', at);
  final end = document.indexOf('</script>', at) + '</script>'.length;
  return document.replaceRange(start, end, '');
}

TransformConfiguration withoutDomTransformers(
  TransformConfiguration config,
  List<Type> removed,
) {
  return TransformConfiguration(
    [
      for (final transformer in config.domTransformers)
        if (!removed.contains(transformer.runtimeType)) transformer,
    ],
    config.textTransformers,
  );
}

Iterable<DisplayCase> casesWhere(
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

bool hasTag(HtmlEmailCorpusFixture fixture, String tag) =>
    !fixture.isPlainText && fixture.html.contains('<$tag');

bool expects(HtmlEmailCorpusFixture fixture, HtmlEmailExpect label) =>
    fixture.expect.contains(label);

Future<List<Violation>> overflowCheck(DisplayRender render) async => overflowRule(render);

Future<List<Violation>> preservationCheck(DisplayRender render) async {
  final fixture = render.displayCase.fixture;
  if (fixture.allowEmptyBody) return const [];
  final kept = bodyWordPreservation(fixture.html, render.transformedHtml);
  return [
    if (kept < fixture.minPreservation)
      Violation('G-preserve', '.tmail-content', '${(kept * 100).toStringAsFixed(1)}% of the words kept'),
    if (bodyLinkDestinations(render.transformedHtml).join(' ') != bodyLinkDestinations(fixture.html).join(' '))
      const Violation('G-preserve', 'a[href]', 'link destinations changed'),
  ];
}
