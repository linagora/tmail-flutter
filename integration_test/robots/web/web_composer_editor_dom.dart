import 'package:web/web.dart' as web;

/// Shared Summernote iframe helpers for web composer Patrol robots.
web.Document? findSummernoteDocument() {
  final iframes = web.document.querySelectorAll('iframe');
  for (var i = 0; i < iframes.length; i++) {
    final iframe = iframes.item(i) as web.HTMLIFrameElement;
    final document = iframe.contentDocument;
    if (document?.querySelector('div.note-editable') != null) {
      return document;
    }
  }
  return null;
}

web.Element? findNoteEditable() =>
    findSummernoteDocument()?.querySelector('div.note-editable');

bool _matchesMarker(web.Element element, String? marker) =>
    marker == null || element.textContent?.contains(marker) == true;

bool _isSignatureElement(web.Element? element) =>
    element != null && element.classList.contains('tmail-signature');

web.Element? _directChildSignature(web.Element editable, String? marker) {
  final children = editable.children;
  for (var i = 0; i < children.length; i++) {
    final child = children.item(i);
    if (!_isSignatureElement(child)) continue;
    if (_matchesMarker(child!, marker)) return child;
  }
  return null;
}

web.Element? _descendantSignature(web.Element editable, String? marker) {
  final all = editable.querySelectorAll('.tmail-signature');
  for (var i = 0; i < all.length; i++) {
    final node = all.item(i);
    if (node is web.Element && _matchesMarker(node, marker)) {
      return node;
    }
  }
  return null;
}

/// Prefers a direct child of `note-editable`, then any descendant. Summernote
/// can wrap saved HTML so the signature is no longer a direct child after reopen.
web.Element? findSignatureElement({String? marker}) {
  final editable = findNoteEditable();
  if (editable == null) return null;
  return _directChildSignature(editable, marker) ??
      _descendantSignature(editable, marker);
}

bool signatureStyleIsHidden(web.Element signature) {
  final style = (signature.getAttribute('style') ?? '').toLowerCase();
  return RegExp(r'display\s*:\s*none').hasMatch(style);
}
