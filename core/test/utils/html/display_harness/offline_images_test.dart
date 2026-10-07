@TestOn('vm')

import 'package:flutter_test/flutter_test.dart';

import 'offline_images.dart';

void main() {
  test('swaps a fixture placeholder for an SVG of its size', () {
    expect(
      swapImagesForOffline('<img src="https://fixture.invalid/cid/120x40">'),
      '<img src="${offlineSvgDataUri(120, 40)}">',
    );
  });

  test('swaps other remote images, srcset and CSS url() to the default size', () {
    final out = swapImagesForOffline(
      '<img src="https://cdn.example/a.png" srcset="//cdn.example/b.png 2x">'
      '<div style="background:url(\'https://cdn.example/bg.png\')">x</div>'
      '<style>.h{background:url(https://cdn.example/h.png)}</style>',
    );
    expect(out, isNot(contains('cdn.example')));
    expect(out, contains(offlineSvgDataUri(600, 300)));
  });

  test('keeps links and visible URLs', () {
    const html = '<a href="https://example.com/x">https://example.com/x</a>';
    expect(swapImagesForOffline(html), html);
  });

  test('swaps a src after a ">" inside an earlier attribute value', () {
    final out = swapImagesForOffline('<img title="Next >" src="https://cdn.example/n.png">');
    expect(out, '<img title="Next >" src="${offlineSvgDataUri(600, 300)}">');
  });

  test('keeps data: values, visible CSS-like text and links', () {
    const html = '<img src="data:image/png;base64,ab//cd">'
        '<p title="url(https://x.example/a)">see url(https://x.example/a)</p>';
    expect(swapImagesForOffline(html), html);
  });

  test('swaps @import and SVG image href', () {
    final out = swapImagesForOffline(
      '<style>@import "https://fonts.example/a.css";</style>'
      '<svg><image href="https://cdn.example/i.png"/></svg>',
    );
    expect(out, isNot(contains('example')));
  });
}
