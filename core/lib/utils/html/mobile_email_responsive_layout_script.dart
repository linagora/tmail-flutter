/// Builds the responsive layout script used only by the native Email View.
///
/// The WebView callback channel is supplied by the generic HTML interaction
/// layer, so this email-specific policy does not depend on that utility class.
class MobileEmailResponsiveLayoutScript {

  /// Reflows overflowing email wrappers while preserving their typography.
  /// Fixed-width tables are scaled only when they cannot be reflowed.
  static String generate({
    required String contentSizeChangedEventJSChannelName,
  }) => '''
    <script type="text/javascript">
      (function() {
$_styleScript
$_measurementScript
$_layoutScript
$_eventScript
      })();
    </script>
  '''.replaceFirst(
    _contentSizeChannelPlaceholder,
    contentSizeChangedEventJSChannelName,
  );

  static const String _contentSizeChannelPlaceholder =
      '__TMAIL_CONTENT_SIZE_CHANNEL__';

  static const String _styleScript = '''
        var style = document.createElement('style');
        var responsiveStyles = [];
        var responsiveLayoutPending = false;
        var lastLayoutWidth = -1;
        style.textContent =
          '.tmail-content .tmail-responsive-layout,' +
          '.tmail-content .tmail-responsive-scale {' +
            '-webkit-text-size-adjust: 100% !important;' +
            'text-size-adjust: 100% !important;' +
          '}' +
          '@media only screen and (max-width: 480px) {' +
            '.tmail-content blockquote.tmail-responsive-quote {' +
              'font-size: 13px !important;' +
            '}' +
          '}';
        (document.head || document.documentElement).appendChild(style);

        function setResponsiveStyle(element, property, value) {
          responsiveStyles.push({
            element: element,
            property: property,
            value: element.style.getPropertyValue(property),
            priority: element.style.getPropertyPriority(property),
          });
          element.style.setProperty(property, value, 'important');
        }

        function clearResponsiveLayout(content) {
          for (var i = responsiveStyles.length - 1; i >= 0; i--) {
            var responsiveStyle = responsiveStyles[i];
            if (responsiveStyle.value) {
              responsiveStyle.element.style.setProperty(
                responsiveStyle.property,
                responsiveStyle.value,
                responsiveStyle.priority,
              );
            } else {
              responsiveStyle.element.style.removeProperty(responsiveStyle.property);
            }
          }
          responsiveStyles = [];

          var responsiveElements = content.querySelectorAll('.tmail-responsive-scale');
          for (var i = 0; i < responsiveElements.length; i++) {
            responsiveElements[i].classList.remove('tmail-responsive-scale');
          }

          var responsiveLayouts = content.querySelectorAll('.tmail-responsive-layout');
          for (var i = 0; i < responsiveLayouts.length; i++) {
            responsiveLayouts[i].classList.remove('tmail-responsive-layout');
          }

          var responsiveQuotes = content.querySelectorAll('.tmail-responsive-quote');
          for (var i = 0; i < responsiveQuotes.length; i++) {
            responsiveQuotes[i].classList.remove('tmail-responsive-quote');
          }
        }
  ''';

  static const String _measurementScript = '''
        function createLayoutMetrics(content) {
          return {
            contentRect: content.getBoundingClientRect(),
            contentWidth: content.clientWidth,
            elementRects: new Map(),
            parentWidths: new Map(),
            overflowingElements: new Map(),
          };
        }

        function getElementRect(element, layoutMetrics) {
          if (!layoutMetrics) return element.getBoundingClientRect();
          if (!layoutMetrics.elementRects.has(element)) {
            layoutMetrics.elementRects.set(element, element.getBoundingClientRect());
          }
          return layoutMetrics.elementRects.get(element);
        }

        function getParentWidth(element, widthFromContent, layoutMetrics) {
          var parent = element.parentElement;
          if (!parent) return widthFromContent;
          if (!layoutMetrics) return parent.clientWidth;
          if (!layoutMetrics.parentWidths.has(parent)) {
            layoutMetrics.parentWidths.set(parent, parent.clientWidth);
          }
          return layoutMetrics.parentWidths.get(parent);
        }

        function getAvailableWidth(content, element, layoutMetrics) {
          var contentRect = layoutMetrics ? layoutMetrics.contentRect : content.getBoundingClientRect();
          var contentWidth = layoutMetrics ? layoutMetrics.contentWidth : content.clientWidth;
          var elementRect = getElementRect(element, layoutMetrics);
          var widthFromContent = contentWidth - Math.max(0, elementRect.left - contentRect.left);
          var parentWidth = getParentWidth(element, widthFromContent, layoutMetrics);
          return Math.max(0, Math.min(widthFromContent, parentWidth || widthFromContent));
        }

        function isElementOverflowing(content, element, layoutMetrics) {
          if (layoutMetrics && layoutMetrics.overflowingElements.has(element)) {
            return layoutMetrics.overflowingElements.get(element);
          }

          var availableWidth = getAvailableWidth(content, element, layoutMetrics);
          var elementWidth = getElementRect(element, layoutMetrics).width;
          var isOverflowing = availableWidth > 0 && elementWidth > availableWidth + 1;
          if (layoutMetrics) {
            layoutMetrics.overflowingElements.set(element, isOverflowing);
          }
          return isOverflowing;
        }

        function getOverflowRoots(content, layoutMetrics) {
          var roots = [];
          var elements = content.getElementsByTagName('*');
          for (var i = 0; i < elements.length; i++) {
            var element = elements[i];
            if (!isElementOverflowing(content, element, layoutMetrics)) continue;

            var parent = element.parentElement;
            if (parent && parent !== content && isElementOverflowing(content, parent, layoutMetrics)) {
              continue;
            }

            roots.push(element);
          }
          return roots;
        }

        function scaleElementToAvailableWidth(content, element, naturalWidth) {
          var availableWidth = getAvailableWidth(content, element);
          if (availableWidth === 0 || naturalWidth <= availableWidth + 1) return 1;

          var scale = availableWidth / naturalWidth;
          element.classList.add('tmail-responsive-scale');
          setResponsiveStyle(element, 'zoom', scale.toString());
          return scale;
        }

        var replacedElements = ['IMG', 'IFRAME', 'VIDEO', 'CANVAS', 'SVG', 'OBJECT', 'EMBED'];

        function isReplacedElement(element) {
          return replacedElements.indexOf(element.tagName) !== -1;
        }

        function wrappableWhiteSpace(whiteSpace) {
          if (whiteSpace === 'nowrap') return 'normal';
          // Preformatted content keeps its spacing and only gains wrapping.
          if (whiteSpace === 'pre') return 'pre-wrap';
          return '';
        }

        function hasFixedWidth(element) {
          var styleWidth = element.style.width;
          var attributeWidth = element.getAttribute('width');
          return (styleWidth && styleWidth.indexOf('%') === -1) ||
              (attributeWidth && attributeWidth.indexOf('%') === -1);
        }

        function getTopLevelTables(element) {
          if (element.tagName === 'TABLE') return [];

          var tables = element.getElementsByTagName('table');
          var topLevelTables = [];
          for (var i = 0; i < tables.length; i++) {
            var table = tables[i];
            var parentTable = table.parentElement && table.parentElement.closest('table');
            if (!parentTable) {
              topLevelTables.push({
                element: table,
                naturalWidth: table.getBoundingClientRect().width,
                hasFixedWidth: hasFixedWidth(table),
              });
            }
          }
          return topLevelTables;
        }

        function getFixedWidthCells(table, naturalWidth) {
          var cells = table.querySelectorAll('td, th, col');
          var fixedWidthCells = [];
          for (var i = 0; i < cells.length; i++) {
            var cell = cells[i];
            if (cell.closest('table') !== table || !hasFixedWidth(cell)) continue;

            var cellWidth = cell.getBoundingClientRect().width;
            if (cellWidth > 0 && naturalWidth > 0) {
              fixedWidthCells.push({
                element: cell,
                width: Math.min(100, cellWidth / naturalWidth * 100),
                paddingLeft: parseFloat(window.getComputedStyle(cell).paddingLeft),
                paddingRight: parseFloat(window.getComputedStyle(cell).paddingRight),
              });
            }
          }
          return fixedWidthCells;
        }

        function collectTableTextElements(table) {
          var textElements = [];
          var elements = table.querySelectorAll('*');
          for (var i = 0; i < elements.length; i++) {
            var element = elements[i];
            var childNodes = element.childNodes;
            for (var j = 0; j < childNodes.length; j++) {
              var childNode = childNodes[j];
              if (childNode.nodeType !== 3 || !childNode.nodeValue || !childNode.nodeValue.trim()) {
                continue;
              }

              var fontSize = parseFloat(window.getComputedStyle(element).fontSize);
              if (isFinite(fontSize)) {
                textElements.push({ element: element, fontSize: fontSize });
              }
              break;
            }
          }
          return textElements;
        }

        function getNestedFixedWidthElements(table) {
          var elements = table.querySelectorAll('td, th, col');
          var fixedWidthElements = [];
          for (var i = 0; i < elements.length; i++) {
            var element = elements[i];
            if (element.closest('table') === table || !hasFixedWidth(element)) continue;

            var width = element.getBoundingClientRect().width;
            if (width > 20) fixedWidthElements.push({ element: element, width: width });
          }
          return fixedWidthElements;
        }
  ''';

  static const String _layoutScript = '''
        function relaxNoWrapContent(content) {
          var elements = content.getElementsByTagName('*');
          var noWrapElements = [];
          for (var i = 0; i < elements.length; i++) {
            var element = elements[i];
            if (element.scrollWidth <= element.clientWidth + 1) continue;

            var computedStyle = window.getComputedStyle(element);
            var whiteSpace = wrappableWhiteSpace(computedStyle.whiteSpace);
            if (!whiteSpace) continue;
            if (computedStyle.overflowX !== 'visible' &&
                computedStyle.overflowX !== 'clip') {
              continue;
            }

            noWrapElements.push({ element: element, whiteSpace: whiteSpace });
          }

          // Style after all measurements to keep the scan free of layout thrash.
          for (var j = 0; j < noWrapElements.length; j++) {
            var noWrapElement = noWrapElements[j];
            setResponsiveStyle(
              noWrapElement.element,
              'white-space',
              noWrapElement.whiteSpace,
            );
          }
        }

        function makeWrapperResponsive(element) {
          setResponsiveStyle(element, 'width', '100%');
          setResponsiveStyle(element, 'max-width', '100%');
        }

        function markResponsiveQuote(element) {
          var quote = element.closest('blockquote');
          if (quote) quote.classList.add('tmail-responsive-quote');
        }

        function markResponsiveLayout(element) {
          element.classList.add('tmail-responsive-layout');
        }

        function makeNestedWrappersResponsive(content, root) {
          makeWrapperResponsive(root);

          // Snapshot after root reflow, then style descendants after all checks.
          var layoutMetrics = createLayoutMetrics(content);
          var elements = root.getElementsByTagName('*');
          var overflowingWrappers = [];
          for (var i = 0; i < elements.length; i++) {
            var element = elements[i];
            if (element.tagName === 'TABLE' || element.closest('table')) continue;
            if (isElementOverflowing(content, element, layoutMetrics)) {
              overflowingWrappers.push(element);
            }
          }

          for (var j = 0; j < overflowingWrappers.length; j++) {
            makeWrapperResponsive(overflowingWrappers[j]);
          }
        }

        function relaxUnbreakableCellText(table) {
          // The document stylesheet forbids breaking words inside cells, which
          // keeps a single long token wider than the screen.
          var cells = table.querySelectorAll('td, th');
          var relaxedCells = [];
          for (var i = 0; i < cells.length; i++) {
            relaxedCells.push({
              element: cells[i],
              whiteSpace: wrappableWhiteSpace(
                window.getComputedStyle(cells[i]).whiteSpace,
              ),
            });
          }

          for (var j = 0; j < relaxedCells.length; j++) {
            var relaxedCell = relaxedCells[j];
            // word-break cannot wrap a cell while its white-space forbids it.
            if (relaxedCell.whiteSpace) {
              setResponsiveStyle(
                relaxedCell.element,
                'white-space',
                relaxedCell.whiteSpace,
              );
            }
            setResponsiveStyle(relaxedCell.element, 'word-break', 'break-word');
          }
        }

        function measureTableColumns(table) {
          var cells = table.querySelectorAll('td, th, col');
          var columns = [];
          var ownerWidths = new Map();
          for (var i = 0; i < cells.length; i++) {
            var cell = cells[i];
            var ownerTable = cell.closest('table');
            if (!ownerTable) continue;

            if (!ownerWidths.has(ownerTable)) {
              ownerWidths.set(ownerTable, ownerTable.getBoundingClientRect().width);
            }
            columns.push({
              element: cell,
              width: cell.getBoundingClientRect().width,
              ownerWidth: ownerWidths.get(ownerTable),
            });
          }
          return columns;
        }

        function makeTableColumnsProportional(table) {
          // Widths from a stylesheet or a nested table are invisible to
          // hasFixedWidth, so proportions are taken from the measured layout.
          var columns = measureTableColumns(table);
          var nestedTables = table.getElementsByTagName('table');
          for (var i = 0; i < nestedTables.length; i++) {
            setResponsiveStyle(nestedTables[i], 'width', '100%');
            setResponsiveStyle(nestedTables[i], 'max-width', '100%');
          }
          for (var j = 0; j < columns.length; j++) {
            var column = columns[j];
            if (column.ownerWidth <= 0 || column.width <= 0) continue;

            setResponsiveStyle(
              column.element,
              'width',
              Math.min(100, column.width / column.ownerWidth * 100).toFixed(3) + '%',
            );
          }
        }

        function fitTableWithinAvailableWidth(content, table, availableWidth) {
          // Breaking long words preserves the type size, so it is tried first.
          relaxUnbreakableCellText(table);
          if (table.getBoundingClientRect().width <= availableWidth + 1) return;

          makeTableColumnsProportional(table);
          if (table.getBoundingClientRect().width <= availableWidth + 1) return;

          scaleElementToAvailableWidth(
            content,
            table,
            table.getBoundingClientRect().width,
          );
        }

        function reflowTableToAvailableWidth(content, table, naturalWidth) {
          var fixedWidthCells = getFixedWidthCells(table, naturalWidth);
          var textElements = collectTableTextElements(table);
          var nestedFixedWidthElements = getNestedFixedWidthElements(table);
          setResponsiveStyle(table, 'width', '100%');
          setResponsiveStyle(table, 'max-width', '100%');
          for (var i = 0; i < fixedWidthCells.length; i++) {
            var fixedWidthCell = fixedWidthCells[i];
            setResponsiveStyle(
              fixedWidthCell.element,
              'width',
              fixedWidthCell.width.toFixed(3) + '%',
            );
          }

          var availableWidth = getAvailableWidth(content, table);
          if (table.getBoundingClientRect().width > availableWidth + 1) {
            fitTableWithinAvailableWidth(content, table, availableWidth);
          } else if (document.documentElement.clientWidth <= 480) {
            var textScale = Math.max(0.7, availableWidth / naturalWidth);
            for (var i = 0; i < fixedWidthCells.length; i++) {
              var fixedWidthCell = fixedWidthCells[i];
              if (fixedWidthCell.paddingLeft > 12) {
                setResponsiveStyle(fixedWidthCell.element, 'padding-left', '12px');
              }
              if (fixedWidthCell.paddingRight > 12) {
                setResponsiveStyle(fixedWidthCell.element, 'padding-right', '12px');
              }
            }
            for (var i = 0; i < nestedFixedWidthElements.length; i++) {
              var fixedWidthElement = nestedFixedWidthElements[i];
              setResponsiveStyle(
                fixedWidthElement.element,
                'width',
                Math.max(20, fixedWidthElement.width * textScale).toFixed(2) + 'px',
              );
            }
            for (var i = 0; i < textElements.length; i++) {
              var textElement = textElements[i];
              if (textElement.fontSize <= 12) continue;

              var responsiveFontSize = Math.max(12, textElement.fontSize * textScale);
              if (responsiveFontSize < textElement.fontSize) {
                setResponsiveStyle(
                  textElement.element,
                  'font-size',
                  responsiveFontSize.toFixed(2) + 'px',
                );
              }
            }
          }
        }

        function applyTextReadableLayout(content, roots) {
          for (var i = 0; i < roots.length; i++) {
            var root = roots[i];
            var tables = getTopLevelTables(root);
            if (tables.length === 0) {
              markResponsiveQuote(root);
              markResponsiveLayout(root);
              if (root.tagName === 'TABLE') {
                reflowTableToAvailableWidth(content, root, root.getBoundingClientRect().width);
              } else if (isReplacedElement(root)) {
                scaleElementToAvailableWidth(content, root, root.getBoundingClientRect().width);
              } else {
                makeWrapperResponsive(root);
                var reflowedWidth = root.getBoundingClientRect().width;
                if (reflowedWidth > getAvailableWidth(content, root) + 1) {
                  scaleElementToAvailableWidth(content, root, reflowedWidth);
                }
              }
              continue;
            }

            makeNestedWrappersResponsive(content, root);
            markResponsiveQuote(root);
            markResponsiveLayout(root);
            for (var j = 0; j < tables.length; j++) {
              var table = tables[j];
              var currentWidth = table.element.getBoundingClientRect().width;
              var naturalWidth = table.hasFixedWidth
                  ? Math.max(table.naturalWidth, currentWidth)
                  : currentWidth;
              if (naturalWidth > getAvailableWidth(content, table.element) + 1) {
                reflowTableToAvailableWidth(content, table.element, naturalWidth);
              }
            }
          }
        }

        function applyResponsiveLayout() {
          var content = document.getElementsByClassName('tmail-content')[0];
          if (!content || content.clientWidth === 0) return;

          try {
            clearResponsiveLayout(content);
            relaxNoWrapContent(content);

            var layoutMetrics = createLayoutMetrics(content);
            var roots = getOverflowRoots(content, layoutMetrics);
            applyTextReadableLayout(content, roots);
            lastLayoutWidth = content.clientWidth;
          } catch (_) {
            clearResponsiveLayout(content);
            lastLayoutWidth = -1;
          }
        }
  ''';

  static const String _eventScript = '''
        function notifyContentSizeChanged() {
          if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
            window.flutter_inappwebview.callHandler('$_contentSizeChannelPlaceholder', '');
          }
        }

        function scheduleResponsiveLayout() {
          if (responsiveLayoutPending) return;
          responsiveLayoutPending = true;

          // Coalesce resize, image and quote events into one layout pass per frame.
          if (window.requestAnimationFrame) {
            window.requestAnimationFrame(function() {
              responsiveLayoutPending = false;
              try {
                applyResponsiveLayout();
              } finally {
                window.requestAnimationFrame(notifyContentSizeChanged);
              }
            });
          } else {
            setTimeout(function() {
              responsiveLayoutPending = false;
              try {
                applyResponsiveLayout();
              } finally {
                notifyContentSizeChanged();
              }
            }, 0);
          }
        }

        if (document.readyState === 'complete') {
          scheduleResponsiveLayout();
        } else {
          window.addEventListener('load', scheduleResponsiveLayout);
        }
        window.addEventListener('resize', function() {
          var content = document.getElementsByClassName('tmail-content')[0];
          if (content && content.clientWidth === lastLayoutWidth) return;

          scheduleResponsiveLayout();
        });
        document.addEventListener('load', function(event) {
          if (event.target && event.target.tagName === 'IMG') {
            scheduleResponsiveLayout();
          }
        }, true);
        document.addEventListener('click', function(event) {
          var target = event.target;
          if (target && target.closest && target.closest('.quote-toggle-button')) {
            scheduleResponsiveLayout();
          }
        });
  ''';
}
