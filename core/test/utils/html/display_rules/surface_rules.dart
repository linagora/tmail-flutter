import 'package:html/parser.dart' show parse;

import '../display_harness/display_case.dart';
import 'generic_rules.dart';

/// Rules a single viewer adds on top of the generic ones.
const surfaceRules = <DisplayViewer, Map<String, DisplayRule>>{
  DisplayViewer.print: {
    'S-print-lazy': printLazyRule,
    'S-print-fit': printFitRule,
  },
};

List<Violation> runSurfaceRules(DisplayRender render) => [
      for (final rule
          in (surfaceRules[render.displayCase.viewer] ?? const {}).values)
        ...rule(render),
    ];

/// Print loads everything at once: no lazy image or background marker left.
List<Violation> printLazyRule(DisplayRender render) {
  final body = parse(render.transformedHtml);
  return [
    for (final img in body.querySelectorAll('img[loading]'))
      Violation('S-print-lazy', 'img', 'loading="${img.attributes['loading']}"'),
    for (final _ in body.querySelectorAll('[lazy]'))
      const Violation('S-print-lazy', '[lazy]', 'lazy background left'),
    for (final _ in body.querySelectorAll('[data-src]'))
      const Violation('S-print-lazy', '[data-src]', 'data-src left'),
  ];
}

/// The print wrapper sits in an auto-layout table, so wide content stretches
/// it and the generic overflow rule sees nothing; measure it against the page.
List<Violation> printFitRule(DisplayRender render) {
  final past = render.frame.content.getBoundingClientRect().right -
      render.displayCase.width;
  return [
    if (past > 1)
      Violation('S-print-fit', '.tmail-content', '+${past.toStringAsFixed(1)}px past the page'),
  ];
}
