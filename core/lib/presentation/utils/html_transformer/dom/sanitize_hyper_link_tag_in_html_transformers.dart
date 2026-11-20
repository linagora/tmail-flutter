import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/presentation/utils/html_transformer/sanitize_url.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/external_link_policy.dart';
import 'package:html/dom.dart';

class SanitizeHyperLinkTagInHtmlTransformer extends DomTransformer {
  final _sanitizeUrl = SanitizeUrl();

  SanitizeHyperLinkTagInHtmlTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    try {
      final elements = document.querySelectorAll('a[href]');

      if (elements.isEmpty) return;

      await Future.wait(elements.map((element) async {
        _sanitizeUrlResource(element);
        _addBlankForTargetProperty(element);
        _addNoReferrerForRelProperty(element);
      }));
    } catch (e) {
      logWarning('$runtimeType::process:Exception = $e');
    }
  }

  void _sanitizeUrlResource(Element element) {
    final rawUrl = element.attributes['href'] ?? '';
    final url = _withDefaultScheme(rawUrl);

    if (_isRelativeUrl(url)) {
      // Relative links cannot be resolved against a trusted base (the email
      // <base> is stripped), so make them inert rather than guessing a host.
      element.attributes.remove('href');
      return;
    }

    final urlSanitized = _sanitizeUrl.process(url);
    final hasAddedScheme = url != rawUrl;
    if (hasAddedScheme && (urlSanitized.isEmpty || _tryDecode(url) == null)) {
      // Fail closed: the raw value is still relative, so the browser would
      // resolve it (e.g. `//www.bank.com@evil.com` lands on evil.com).
      // SanitizeUrl returns its input when decoding fails, so that is a
      // rejection too.
      element.attributes.remove('href');
      return;
    }

    final keptUrl = urlSanitized.isNotEmpty ? urlSanitized : url;
    if (ExternalLinkPolicy.canKeepInContent(_trimBrowserWhitespace(keptUrl))) {
      element.attributes['href'] = keptUrl;
    } else {
      element.attributes.remove('href');
    }
  }

  /// Only scheme-less hrefs that unambiguously name a host get `https`.
  /// A "looks like a domain" check would turn `setup.zip` into a real host.
  String _withDefaultScheme(String url) {
    final trimmedUrl = _trimBrowserWhitespace(url);
    if (trimmedUrl.startsWith('//')) return 'https:$trimmedUrl';
    if (trimmedUrl.toLowerCase().startsWith('www.')) return 'https://$trimmedUrl';
    return url;
  }

  bool _isRelativeUrl(String url) {
    final trimmedUrl = _trimBrowserWhitespace(url);
    if (trimmedUrl.startsWith('#')) return false;
    // The browser reads the raw value: `https%3A//x` and an empty href are relative to the app page.
    final uri = Uri.tryParse(trimmedUrl);
    return uri == null || !uri.hasScheme;
  }

  /// Strips only what the browser URL parser strips (C0 controls and space).
  /// `String.trim` also drops U+00A0 and U+FEFF, which the browser keeps, making the href relative.
  String _trimBrowserWhitespace(String url) {
    var start = 0;
    var end = url.length;
    while (start < end && url.codeUnitAt(start) <= 0x20) {
      start++;
    }
    while (end > start && url.codeUnitAt(end - 1) <= 0x20) {
      end--;
    }
    return url.substring(start, end);
  }

  String? _tryDecode(String url) {
    try {
      return Uri.decodeFull(url);
    } catch (_) {
      return null;
    }
  }

  void _addBlankForTargetProperty(Element element) {
    element.attributes['target'] = '_blank';
  }

  void _addNoReferrerForRelProperty(Element element) {
    final rel = element.attributes['rel'];
    if (rel == null || (!rel.contains('noopener') && !rel.contains('noreferrer'))) {
      element.attributes['rel'] = 'noreferrer';
    }
  }
}
