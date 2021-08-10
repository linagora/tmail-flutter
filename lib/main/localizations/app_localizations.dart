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
}

