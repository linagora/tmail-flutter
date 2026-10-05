import 'package:tmail_ui_user/main/routes/route_utils.dart';

typedef OpenMailtoLinkAction = void Function(Uri uri);
typedef LaunchPdfLinkAction = void Function(String url);

/// Links come from an untrusted PDF: only `http`, `https` and `mailto` are
/// opened, so a `javascript:` link can never run on the app origin.
class PdfLinkTapHandler {
  static const Set<String> _launchableSchemes = {
    'http',
    'https',
    RouteUtils.mailtoPrefix,
  };

  const PdfLinkTapHandler({
    required this.launchLinkAction,
    this.mailtoAction,
  });

  final LaunchPdfLinkAction launchLinkAction;
  final OpenMailtoLinkAction? mailtoAction;

  void handle(Uri uri) {
    final mailtoAction = this.mailtoAction;
    if (uri.scheme == RouteUtils.mailtoPrefix && mailtoAction != null) {
      mailtoAction(uri);
    } else if (_launchableSchemes.contains(uri.scheme)) {
      launchLinkAction(uri.toString());
    }
  }
}
