import 'package:workplace/domain/entity/drive_document.dart';

extension DriveDocumentExtension on DriveDocument {
  /// HTML-embedded link: scheme still validated since the browser follows it directly.
  bool isAttachableAsLink({required bool requireHttps}) =>
      sharingLink?.isSafeLinkScheme(requireHttps: requireHttps) ?? false;

  /// Backend fetches this via JMAP, so no scheme gate is needed.
  /// An empty link is rejected here so it never reaches the backend.
  /// Link precedence lives at the call site, not here.
  bool isAttachableAsDownload() =>
      downloadLink?.toString().trim().isNotEmpty ?? false;
}

extension _SafeLinkSchemeExtension on Uri {
  /// Allowlist, not a denylist: anything else (`javascript:`, `data:`, ...) is
  /// executable once embedded in composer HTML.
  bool isSafeLinkScheme({required bool requireHttps}) =>
      isScheme('https') || (!requireHttps && isScheme('http'));
}
