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

typedef _ElementFilter = bool Function(web.Element element);

_ElementFilter _containsMarker(String? marker) => (element) =>
    marker == null || element.textContent?.contains(marker) == true;

bool _isSignatureElement(web.Element? element) =>
    element != null && element.classList.contains('tmail-signature');

web.Element? _directChildSignature(
  web.Element editable,
  _ElementFilter matches,
) {
  final children = editable.children;
  for (var i = 0; i < children.length; i++) {
    final child = children.item(i);
    if (_isSignatureElement(child) && matches(child!)) return child;
  }
  return null;
}

List<web.Element> _descendantSignatures(
  web.Element editable,
  _ElementFilter matches,
) {
  final all = editable.querySelectorAll('.tmail-signature');
  return [
    for (var i = 0; i < all.length; i++)
      if (all.item(i) case final web.Element node when matches(node)) node,
  ];
}

/// Prefers a direct child of `note-editable`, then any descendant. Summernote
/// can wrap saved HTML so the signature is no longer a direct child after reopen.
web.Element? findSignatureElement({String? marker}) {
  final editable = findNoteEditable();
  if (editable == null) return null;
  final matches = _containsMarker(marker);
  return _directChildSignature(editable, matches) ??
      _descendantSignatures(editable, matches).firstOrNull;
}

/// Simulates Enter then typing at the end of [signature]: the editor splits
/// the block, so the text lands in a sibling copy of the signature element.
void splitSignatureWithText(web.Element signature, String text) {
  final part = signature.cloneNode() as web.Element
    ..appendChild(web.document.createTextNode(text));
  signature.parentNode!.insertBefore(part, signature.nextSibling);
}

bool signatureStyleIsHidden(web.Element signature) {
  final style = (signature.getAttribute('style') ?? '').toLowerCase();
  return RegExp(r'display\s*:\s*none').hasMatch(style);
}

/// Every signature currently in the editor, whatever its nesting.
List<web.Element> findAllSignatureElements({String? marker}) {
  final editable = findNoteEditable();
  if (editable == null) return const [];
  return _descendantSignatures(editable, _containsMarker(marker));
}
