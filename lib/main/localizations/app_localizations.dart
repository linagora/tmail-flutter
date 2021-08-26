import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tmail_ui_user/l10n/messages_all.dart';

class AppLocalizations {

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static Future<AppLocalizations> load(Locale locale) async {
    final name = locale.countryCode == null ? locale.languageCode : locale.toString();

    final localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  String get initializing_data {
    return Intl.message('Initializing data...',
      name: 'initializing_data');
  }

  String get login_text_slogan {
    return Intl.message('TMail',
        name: 'login_text_slogan');
  }

  String get prefix_https {
    return Intl.message('https://',
        name: 'prefix_https');
  }

  String get username {
    return Intl.message('username',
        name: 'username');
  }

  String get password {
    return Intl.message('password',
        name: 'password');
  }

  String get login {
    return Intl.message('Login',
        name: 'login');
  }

  String get login_text_login_to_continue {
    return Intl.message('Please login to continue',
        name: 'login_text_login_to_continue');
  }

  String get unknown_error_login_message {
    return Intl.message('Unknown error occurred, please try again',
        name: 'unknown_error_login_message');
  }

  String get search_folder {
    return Intl.message(
      'Search folder',
      name: 'search_folder',
    );
  }

  String get storage {
    return Intl.message(
      'STORAGE',
      name: 'storage',
    );
  }

  String get my_folders {
    return Intl.message(
      'MY FOLDERS',
      name: 'my_folders',
    );
  }

  String get new_folder {
    return Intl.message(
      'New folder',
      name: 'new_folder',
    );
  }

  String get reply_all {
    return Intl.message(
      'Reply all',
      name: 'reply_all',
    );
  }

  String get reply {
    return Intl.message(
      'Reply',
      name: 'reply',
    );
  }

  String get forward {
    return Intl.message(
      'Forward',
      name: 'forward',
    );
  }

  String get no_emails {
    return Intl.message(
      'No emails',
      name: 'no_emails',
    );
  }

  String get no_mail_selected {
    return Intl.message(
      'No email selected',
      name: 'no_mail_selected',
    );
  }

  String get from_email_address_prefix {
    return Intl.message(
      'From',
      name: 'from_email_address_prefix',
    );
  }

  String get to_email_address_prefix {
    return Intl.message(
      'To',
      name: 'to_email_address_prefix',
    );
  }

  String get unread_email_notification {
    return Intl.message(
      'new',
      name: 'unread_email_notification',
    );
  }

  String get bcc_email_address_prefix {
    return Intl.message(
      'Bcc',
      name: 'bcc_email_address_prefix',
    );
  }

  String get cc_email_address_prefix {
    return Intl.message(
      'Cc',
      name: 'cc_email_address_prefix',
    );
  }

  String get hint_text_email_address {
    return Intl.message(
      'Name or email address',
      name: 'hint_text_email_address',
    );
  }

  String get subject_email {
    return Intl.message(
      'Subject',
      name: 'subject_email',
    );
  }

  String get hint_content_email_composer {
    return Intl.message(
      'Start writing your email here',
      name: 'hint_content_email_composer',
    );
  }

  String header_email_quoted(String sentDate, String emailAddress) {
    return Intl.message(
        'On $sentDate, from $emailAddress',
        name: 'header_email_quoted',
        args: [sentDate, emailAddress]
    );
  }

  String get prefix_reply_email {
    return Intl.message(
      'Re:',
      name: 'prefix_reply_email',
    );
  }

  String get prefix_forward_email {
    return Intl.message(
      'Fwd:',
      name: 'prefix_forward_email',
    );
  }
}

