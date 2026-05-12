import 'package:core/utils/html/html_interaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HtmlInteraction iframe find scripts', () {
    test('SHOULD intercept browser find shortcut inside iframe', () {
      final script = HtmlInteraction.scriptHandleIframeFindShortcutListener(
        'view-1',
      );

      expect(script, contains("key === 'f'"));
      expect(script, contains('event.ctrlKey || event.metaKey'));
      expect(script, contains('event.preventDefault()'));
      expect(script, contains('event.stopImmediatePropagation()'));
      expect(
        script,
        contains('toDart: ${HtmlInteraction.iframeFindShortcutEvent}'),
      );
    });

    test('SHOULD generate content find highlighter script', () {
      final script = HtmlInteraction.scriptHandleIframeContentFind('view-1');

      expect(script, contains('document.createTreeWalker'));
      expect(script, contains('NodeFilter.SHOW_TEXT'));
      expect(script, contains('mark.tmail-find-hit'));
      expect(script, contains('tmail-find-hit-active'));
      expect(script, contains('scrollIntoView'));
      expect(script, contains(HtmlInteraction.iframeFindApplyEvent));
      expect(script, contains(HtmlInteraction.iframeFindNextEvent));
      expect(script, contains(HtmlInteraction.iframeFindPreviousEvent));
      expect(script, contains(HtmlInteraction.iframeFindClearEvent));
      expect(
        script,
        contains('toDart: ${HtmlInteraction.iframeFindResultEvent}'),
      );
    });
  });
}
