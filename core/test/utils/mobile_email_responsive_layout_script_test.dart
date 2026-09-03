import 'package:core/utils/html/mobile_email_responsive_layout_script.dart';
import 'package:flutter_test/flutter_test.dart';

const _contentSizeChangedEventJSChannelName = 'MobileEmailContentSizeChanged';

void expectScriptMatches(String script, List<Matcher> matchers) {
  expect(script, allOf(matchers));
}

void expectScriptOrder(String script, List<String> tokens) {
  var index = -1;
  for (final token in tokens) {
    index = script.indexOf(token, index + 1);
    if (index < 0) break;
  }

  expect(index, greaterThanOrEqualTo(0));
}

String generateMobileEmailResponsiveLayoutScript() =>
    MobileEmailResponsiveLayoutScript.generate(
      contentSizeChangedEventJSChannelName:
          _contentSizeChangedEventJSChannelName,
    );

void main() {
  group('MobileEmailResponsiveLayoutScript', () {
    test('generates an executable script with the registered size-change channel', () {
      final script = generateMobileEmailResponsiveLayoutScript();

      expectScriptMatches(script, [
        contains('<script type="text/javascript">'),
        contains('</script>'),
        contains("callHandler('$_contentSizeChangedEventJSChannelName'"),
        isNot(contains('__TMAIL_CONTENT_SIZE_CHANNEL__')),
      ]);
    });

    test('keeps outer quote typography independent from table reflow', () {
      final script = generateMobileEmailResponsiveLayoutScript();

      expectScriptMatches(script, [
        contains("document.createElement('style')"),
        contains('.tmail-responsive-layout'),
        contains('.tmail-responsive-scale'),
        contains('text-size-adjust: 100% !important'),
        contains('.tmail-content blockquote.tmail-responsive-quote'),
        contains('@media only screen and (max-width: 480px)'),
        contains('font-size: 13px !important'),
        contains("element.classList.add('tmail-responsive-layout')"),
        isNot(contains('normalizeResponsiveQuoteTypography')),
        isNot(contains('getResponsiveTextScale')),
      ]);
    });

    test('measures and changes only overflowing layout blocks', () {
      final script = generateMobileEmailResponsiveLayoutScript();

      expectScriptMatches(script, [
        contains('createLayoutMetrics'),
        contains('elementRects'),
        contains('parentWidths'),
        contains('overflowingElements'),
        contains('getAvailableWidth'),
        contains('return Math.max(0, Math.min(widthFromContent'),
        contains("setResponsiveStyle(element, 'zoom'"),
        contains("setResponsiveStyle(element, 'width', '100%')"),
        contains("setResponsiveStyle(element, 'max-width', '100%')"),
        contains('hasFixedWidth'),
        contains('getTopLevelTables'),
        contains("parentElement.closest('table')"),
      ]);
    });

    test('restores every temporary style and responsive marker before remeasuring', () {
      final script = generateMobileEmailResponsiveLayoutScript();

      expectScriptMatches(script, [
        contains('responsiveStyles.length - 1'),
        contains('element.style.removeProperty(responsiveStyle.property)'),
        contains("classList.remove('tmail-responsive-scale')"),
        contains("classList.remove('tmail-responsive-layout')"),
        contains("classList.remove('tmail-responsive-quote')"),
      ]);
      expectScriptOrder(script, [
        'clearResponsiveLayout(content);',
        'var layoutMetrics = createLayoutMetrics(content);',
        'catch (_)',
        'clearResponsiveLayout(content);',
      ]);
    });

    test('reflows fixed-width table cells before using scale as a fallback', () {
      final script = generateMobileEmailResponsiveLayoutScript();
      final reflowStart = script.indexOf('function reflowTableToAvailableWidth');
      final fixedWidthCells = script.indexOf(
        'var fixedWidthCells = getFixedWidthCells(table, naturalWidth);',
        reflowStart,
      );
      final fallbackScale = script.indexOf(
        'scaleElementToAvailableWidth(content, table, table.getBoundingClientRect().width);',
        reflowStart,
      );
      final reflowEnd = script.indexOf('function applyTextReadableLayout', reflowStart);
      final reflowScript = script.substring(reflowStart, reflowEnd);

      expect(
        reflowStart > -1 && fixedWidthCells > reflowStart && fallbackScale > fixedWidthCells,
        isTrue,
      );
      expectScriptMatches(reflowScript, [
        contains("setResponsiveStyle(table, 'width', '100%')"),
        contains("setResponsiveStyle(table, 'max-width', '100%')"),
        contains('fixedWidthCell.element'),
        contains("'width'"),
        contains('fixedWidthCell.paddingLeft'),
        contains('fixedWidthCell.paddingRight'),
      ]);
      expectScriptMatches(script, [
        contains("cell.closest('table') !== table"),
      ]);
    });

    test('reduces only reflowed table typography on narrow screens', () {
      final script = generateMobileEmailResponsiveLayoutScript();
      final collectStart = script.indexOf('function collectTableTextElements');
      final collectEnd = script.indexOf('function getNestedFixedWidthElements', collectStart);
      final collectTableTextElements = script.substring(collectStart, collectEnd);

      expectScriptMatches(script, [
        contains('collectTableTextElements(table)'),
        contains('getNestedFixedWidthElements(table)'),
        contains("element.closest('table') === table || !hasFixedWidth(element)"),
        contains('document.documentElement.clientWidth <= 480'),
        contains('Math.max(0.7, availableWidth / naturalWidth)'),
        contains('fixedWidthCell.paddingLeft > 12'),
        contains('fixedWidthCell.paddingRight > 12'),
        contains("'padding-left'"),
        contains("'padding-right'"),
        contains("Math.max(20, fixedWidthElement.width * textScale).toFixed(2) + 'px'"),
        contains('if (textElement.fontSize <= 12) continue'),
        contains("'font-size'"),
        contains("responsiveFontSize.toFixed(2) + 'px'"),
      ]);
      expect(collectTableTextElements, isNot(contains("closest('table') !== table")));
    });

    test('collects nested overflowing wrappers before applying their responsive styles', () {
      final script = generateMobileEmailResponsiveLayoutScript();
      final nestedWrapperStart = script.indexOf('function makeNestedWrappersResponsive');
      final nestedWrapperEnd = script.indexOf('function reflowTableToAvailableWidth', nestedWrapperStart);
      final nestedWrapperScript = script.substring(nestedWrapperStart, nestedWrapperEnd);

      expectScriptMatches(nestedWrapperScript, [
        contains('createLayoutMetrics(content)'),
        contains('var overflowingWrappers = []'),
        contains('isElementOverflowing(content, element, layoutMetrics)'),
        contains('makeWrapperResponsive(overflowingWrappers[j])'),
      ]);
      expectScriptOrder(nestedWrapperScript, [
        'makeWrapperResponsive(root)',
        'createLayoutMetrics(content)',
        'var overflowingWrappers = []',
        'isElementOverflowing(content, element, layoutMetrics)',
        'makeWrapperResponsive(overflowingWrappers[j])',
      ]);
    });

    test('reflows a table when it is the overflow root', () {
      final script = generateMobileEmailResponsiveLayoutScript();
      final tableRootBranch = script.indexOf("if (root.tagName === 'TABLE')");
      final reflow = script.indexOf('reflowTableToAvailableWidth(content, root', tableRootBranch);
      final genericScale = script.indexOf('scaleElementToAvailableWidth', tableRootBranch);

      expect(
        tableRootBranch > -1 && reflow > tableRootBranch && genericScale > reflow,
        isTrue,
      );
    });

    test('remeasures after content-size events without scheduling duplicate layout work', () {
      final script = generateMobileEmailResponsiveLayoutScript();

      expectScriptMatches(script, [
        contains('responsiveLayoutPending'),
        contains('window.requestAnimationFrame'),
        contains("window.addEventListener('load', scheduleResponsiveLayout)"),
        contains("window.addEventListener('resize', scheduleResponsiveLayout)"),
        contains("event.target.tagName === 'IMG'"),
        contains("closest('.quote-toggle-button')"),
        contains('setTimeout(function()'),
      ]);
    });
  });
}
