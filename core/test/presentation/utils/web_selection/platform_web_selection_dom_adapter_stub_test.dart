@TestOn('vm')

import 'package:core/presentation/utils/web_selection/platform_web_selection_dom_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('non-web DOM adapter remains a no-op', () {
    final adapter = PlatformWebSelectionDomAdapter();
    var blurCalls = 0;

    expect(adapter.isIframeFocused, isFalse);
    expect(adapter.clearIframeSelections, returnsNormally);
    expect(
      () => adapter.addTopWindowBlurListener(() => blurCalls++),
      returnsNormally,
    );
    expect(adapter.removeTopWindowBlurListener, returnsNormally);
    expect(blurCalls, 0);
  });
}
