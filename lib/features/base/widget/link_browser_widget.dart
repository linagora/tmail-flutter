
import 'package:flutter/widgets.dart';
import 'package:url_launcher/link.dart';

class LinkBrowserWidget extends StatelessWidget {

  final Uri uri;
  final Widget child;

  const LinkBrowserWidget({
    Key? key,
    required this.uri,
    required this.child
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Link(
      uri: uri,
      builder: (context, function) => child
    );
  }
}