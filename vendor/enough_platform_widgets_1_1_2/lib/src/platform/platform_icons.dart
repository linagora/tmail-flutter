import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_info.dart';

/// Common icons for both cupertino and material
class CommonPlatformIcons {
  CommonPlatformIcons._();

  static final _isCupertino = PlatformInfo.isCupertino;

  static IconData get ok =>
      _isCupertino ? CupertinoIcons.check_mark : Icons.done;

  static IconData get cancel =>
      _isCupertino ? CupertinoIcons.clear : Icons.cancel;

  static IconData get clear =>
      _isCupertino ? CupertinoIcons.xmark_circle_fill : Icons.clear;

  static IconData get bold =>
      _isCupertino ? CupertinoIcons.bold : Icons.format_bold;

  static IconData get italic =>
      _isCupertino ? CupertinoIcons.italic : Icons.format_italic;

  static IconData get underlined =>
      _isCupertino ? CupertinoIcons.underline : Icons.format_underline;

  static IconData get strikethrough =>
      _isCupertino ? CupertinoIcons.strikethrough : Icons.format_strikethrough;

  static IconData get info => _isCupertino ? CupertinoIcons.info : Icons.info;

  static IconData get add => _isCupertino ? CupertinoIcons.add : Icons.add;

  static IconData get copy =>
      _isCupertino ? CupertinoIcons.rectangle_on_rectangle : Icons.copy;

  static IconData get delete =>
      _isCupertino ? CupertinoIcons.delete : Icons.delete;

  static IconData get edit => _isCupertino ? CupertinoIcons.pencil : Icons.edit;

  static IconData get send =>
      _isCupertino ? CupertinoIcons.paperplane : Icons.send;

  static IconData get settings =>
      _isCupertino ? CupertinoIcons.settings : Icons.settings;

  static IconData get refresh =>
      _isCupertino ? CupertinoIcons.refresh : Icons.refresh;

  static IconData get person =>
      _isCupertino ? CupertinoIcons.person : Icons.person;

  static IconData get group =>
      _isCupertino ? CupertinoIcons.group : Icons.group;

  static IconData get account =>
      _isCupertino ? CupertinoIcons.person_circle : Icons.account_circle;

  static IconData get mailUnread =>
      _isCupertino ? CupertinoIcons.envelope_badge : Icons.mark_email_unread;

  static IconData get mailRead => _isCupertino
      ? CupertinoIcons.envelope_open
      : Icons.mark_email_read_outlined;
}
