import 'package:core/presentation/extensions/html_document_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HtmlDocumentExtension::toHtmlFragment test:', () {
    test(
      'Should return the body inner HTML\n'
      'When the document has no <style> in <head>',
    () {
      const document = '<html><head></head><body><p>Alice</p></body></html>';

      expect(document.toHtmlFragment(), '<p>Alice</p>');
    });

    test(
      'Should prepend the head stylesheet to the body fragment\n'
      'When the document carries a <style> block in <head>',
    () {
      const document = '<html><head><style>.sig{color:#093}</style></head>'
          '<body><p class="sig">Alice</p></body></html>';

      expect(
        document.toHtmlFragment(),
        '<style>.sig{color:#093}</style><p class="sig">Alice</p>',
      );
    });

    test(
      'Should keep every stylesheet in document order\n'
      'When the document carries multiple <style> blocks in <head>',
    () {
      const document =
          '<html><head><style>.a{}</style><style>.b{}</style></head>'
          '<body><p>Alice</p></body></html>';

      expect(
        document.toHtmlFragment(),
        '<style>.a{}</style><style>.b{}</style><p>Alice</p>',
      );
    });

    test(
      'Should return only the stylesheet\n'
      'When the document body is empty',
    () {
      const document = '<html><head><style>.sig{}</style></head>'
          '<body></body></html>';

      expect(document.toHtmlFragment(), '<style>.sig{}</style>');
    });

    test(
      'Should return the content as a body fragment\n'
      'When the input is a bare fragment instead of a complete document',
    () {
      const fragment = '<p style="line-height:1.5">Alice</p>';

      expect(fragment.toHtmlFragment(), fragment);
    });

    test(
      'Should return an empty string\n'
      'When the input is empty',
    () {
      expect(''.toHtmlFragment(), '');
    });
  });
}
