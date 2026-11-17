import 'dart:math';

import 'package:core/presentation/utils/html_transformer/linear_time_linkifiers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkify/linkify.dart';

void main() {
  const autolinkOptions = LinkifyOptions(
    humanize: true,
    looseUrl: true,
    defaultToHttps: true,
    removeWww: true,
  );
  const optionsMatrix = [
    autolinkOptions,
    LinkifyOptions(),
    LinkifyOptions(looseUrl: true, humanize: false, excludeLastPeriod: false),
  ];
  const packageLinkifiers = [EmailLinkifier(), UrlLinkifier()];
  const linearTimeLinkifiers = [LinearTimeEmailLinkifier(), LinearTimeUrlLinkifier()];

  String describe(List<LinkifyElement> elements) => elements
      .map((e) => e is LinkableElement
          ? '${e.runtimeType}(${e.text}|${e.url}|${e.originText})'
          : '${e.runtimeType}(${e.text})')
      .join(' ');

  void expectSameAsPackage(String text) {
    for (final options in optionsMatrix) {
      expect(
        describe(linkify(text, options: options, linkifiers: linearTimeLinkifiers)),
        describe(linkify(text, options: options, linkifiers: packageLinkifiers)),
        reason: 'text: "$text", options: looseUrl=${options.looseUrl}',
      );
      expect(
        describe(linkify(text, options: options, linkifiers: linearTimeLinkifiers.reversed.toList())),
        describe(linkify(text, options: options, linkifiers: packageLinkifiers.reversed.toList())),
        reason: 'reversed order, text: "$text", options: looseUrl=${options.looseUrl}',
      );
    }
  }

  group('LinearTimeEmailLinkifier and LinearTimeUrlLinkifier', () {
    group('SHOULD produce the same elements as the linkify package', () {
      const cases = {
        'plain text': 'hello world',
        'email in text': 'write to john.doe+tag@example.com today',
        'mailto prefix': 'mailto:john@example.com',
        'uppercase mailto prefix': 'MAILTO:john@example.com',
        'mailto ending a previous run': 'xmailto:a@b.cc',
        'repeated mailto prefix': 'mailto:mailto:a@b.cc',
        'chained addresses': 'a@b@c.dd a@b.cc.dd@e.ff a@b.cc1x@e.ff',
        'address without tld': 'a@b and a@b.c',
        'url with protocol': 'see https://example.com/path?q=1#top.',
        'www url': 'go to www.example.org.',
        'loose url': 'visit example.com/a-b and b.co',
        'urls separated by markup': 'www.a.bc<www.d.ef>x@y.zz',
        'url with trailing period': 'https://a.bc.',
        'special characters': '<>&"\'=/\\:@.%#?|-+ www.a.b/x https://q.r x@y.z',
        'non ascii text': 'café@exämple.com été.fr',
      };
      cases.forEach((name, text) => test(name, () => expectSameAsPackage(text)));

      test('on seeded random inputs', () {
        const atoms = [
          'a', 'Z', '1', '.', '@', '-', '_', '%', '+', ':', '/', '#', '?', '=',
          '&', '"', "'", '<', '>', ' ', '\n', 'www.', 'http://', 'https://',
          'mailto:', 'MAILTO:', 'x@y.zz', 'b.com', '.cc', 'é', '~', '`',
        ];
        final random = Random(5097);
        for (var i = 0; i < 20000; i++) {
          final length = random.nextInt(30);
          expectSameAsPackage(
            List.generate(length, (_) => atoms[random.nextInt(atoms.length)]).join(),
          );
        }
      });
    });

    test('SHOULD linkify a 100 KB run of local-part characters in linear time', () {
      final watch = Stopwatch()..start();

      final elements = linkify(
        '${'a' * 100000}@',
        options: autolinkOptions,
        linkifiers: const [LinearTimeEmailLinkifier()],
      );

      expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
      expect(elements, hasLength(1));
    });

    test('SHOULD linkify 50000 URLs in linear time', () {
      final watch = Stopwatch()..start();

      final elements = linkify(
        'www.a.bc<' * 50000,
        options: autolinkOptions,
        linkifiers: const [LinearTimeUrlLinkifier()],
      );

      expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
      expect(elements.whereType<UrlElement>(), hasLength(50000));
    });

    test('SHOULD linkify 20000 back-to-back addresses without overflowing the stack', () {
      final elements = linkify(
        'x@y.z' * 20000,
        options: autolinkOptions,
        linkifiers: linearTimeLinkifiers,
      );

      expect(elements.whereType<EmailElement>().length, greaterThan(1000));
    });
  });
}
