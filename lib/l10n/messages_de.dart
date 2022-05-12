// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, always_declare_return_types

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef String MessageIfAbsent(String? messageStr, List<Object>? args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'de';

  static m0(count) => "${count} Anhänge";

  static m1(count) => "${count} ausgewählt";

  static m2(fileName) => "${fileName} wird heruntergeladen";

  static m3(sentDate, emailAddress) => "Am ${sentDate}, von ${emailAddress}";

  static m4(count) => "${count} Element als gelesen markiert";

  static m5(count) => "${count} Element als ungelesen markiert";

  static m6(count) => "${count} Elemente mit einem Stern markiert";

  static m7(count) => "${count} Elemente als nicht wichtig markiert";

  static m8(destinationMailboxPath) => "Verschoben nach ${destinationMailboxPath}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function> {
    "an_error_occurred" : MessageLookupByLibrary.simpleMessage("Fehler! Ein Fehler ist aufgetreten. Bitte versuchen Sie es später erneut."),
    "attach_file_prepare_text" : MessageLookupByLibrary.simpleMessage("Vorbereiten des Dateianhangs …"),
    "attachment_download_failed" : MessageLookupByLibrary.simpleMessage("Herunterladen von Anlagen fehlgeschlagen"),
    "attachments_uploaded_successfully" : MessageLookupByLibrary.simpleMessage("Anhänge erfolgreich hochgeladen"),
    "bcc_email_address_prefix" : MessageLookupByLibrary.simpleMessage("Bcc"),
    "browse" : MessageLookupByLibrary.simpleMessage("Durchsuchen"),
    "can_not_upload_this_file_as_attachments" : MessageLookupByLibrary.simpleMessage("Diese Datei kann nicht als Anhang hochgeladen werden"),
    "cancel" : MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "cc_email_address_prefix" : MessageLookupByLibrary.simpleMessage("Cc"),
    "count_attachment" : m0,
    "count_email_selected" : m1,
    "downloading_file" : m2,
    "email" : MessageLookupByLibrary.simpleMessage("E-Mail"),
    "forward" : MessageLookupByLibrary.simpleMessage("Weiterleiten"),
    "from_email_address_prefix" : MessageLookupByLibrary.simpleMessage("Von"),
    "header_email_quoted" : m3,
    "hint_content_email_composer" : MessageLookupByLibrary.simpleMessage("Beginnen Sie hier mit dem Schreiben Ihrer E-Mail"),
    "hint_text_email_address" : MessageLookupByLibrary.simpleMessage("Name oder E-Mail-Adresse"),
    "initializing_data" : MessageLookupByLibrary.simpleMessage("Daten werden initialisiert …"),
    "login" : MessageLookupByLibrary.simpleMessage("Anmelden"),
    "login_text_login_to_continue" : MessageLookupByLibrary.simpleMessage("Bitte melden Sie sich an, um fortzufahren"),
    "login_text_slogan" : MessageLookupByLibrary.simpleMessage("Team Mail"),
    "mark_as_read" : MessageLookupByLibrary.simpleMessage("Als gelesen markieren"),
    "mark_as_unread" : MessageLookupByLibrary.simpleMessage("Ungelesen markieren"),
    "marked_multiple_item_as_read" : m4,
    "marked_multiple_item_as_unread" : m5,
    "marked_star_multiple_item" : m6,
    "marked_unstar_multiple_item" : m7,
    "move_to_spam" : MessageLookupByLibrary.simpleMessage("In Spam verschieben"),
    "move_to_trash" : MessageLookupByLibrary.simpleMessage("In Papierkorb verschieben"),
    "moved_to_mailbox" : m8,
    "my_folders" : MessageLookupByLibrary.simpleMessage("MEINE ORDNER"),
    "new_folder" : MessageLookupByLibrary.simpleMessage("Neuer Ordner"),
    "no_emails" : MessageLookupByLibrary.simpleMessage("Keine E-Mails in diesem Postfach"),
    "no_emails_matching_your_search" : MessageLookupByLibrary.simpleMessage("Es wurden keine E-Mails zu Ihrer Suche gefunden"),
    "no_mail_selected" : MessageLookupByLibrary.simpleMessage("Keine E-Mail ausgewählt"),
    "password" : MessageLookupByLibrary.simpleMessage("Passwort"),
    "photos_and_videos" : MessageLookupByLibrary.simpleMessage("Fotos und Videos"),
    "pick_attachments" : MessageLookupByLibrary.simpleMessage("Anhänge auswählen"),
    "prefix_forward_email" : MessageLookupByLibrary.simpleMessage("Wtr:"),
    "prefix_https" : MessageLookupByLibrary.simpleMessage("https://"),
    "prefix_reply_email" : MessageLookupByLibrary.simpleMessage("Re:"),
    "prefix_suggestion_search" : MessageLookupByLibrary.simpleMessage("Suche nach"),
    "preparing_to_export" : MessageLookupByLibrary.simpleMessage("Vorbereitungen für den Export"),
    "reply" : MessageLookupByLibrary.simpleMessage("Antworten"),
    "reply_all" : MessageLookupByLibrary.simpleMessage("Alle antworten"),
    "results" : MessageLookupByLibrary.simpleMessage("Ergebnisse"),
    "search_folder" : MessageLookupByLibrary.simpleMessage("Ordner durchsuchen"),
    "search_mail" : MessageLookupByLibrary.simpleMessage("E-Mails durchsuchen"),
    "storage" : MessageLookupByLibrary.simpleMessage("SPEICHER"),
    "subject_email" : MessageLookupByLibrary.simpleMessage("Betreff"),
    "to_email_address_prefix" : MessageLookupByLibrary.simpleMessage("An"),
    "undo_action" : MessageLookupByLibrary.simpleMessage("RÜCKGÄNGIG"),
    "unknown_error_login_message" : MessageLookupByLibrary.simpleMessage("Ein unbekannter Fehler ist aufgetreten. Bitte versuchen Sie es erneut."),
    "unread_email_notification" : MessageLookupByLibrary.simpleMessage("neu"),
    "user_cancel_download_file" : MessageLookupByLibrary.simpleMessage("Benutzer bricht das Herunterladen ab"),
    "you_need_to_grant_files_permission_to_download_attachments" : MessageLookupByLibrary.simpleMessage("Sie müssen die Datei-Erlaubnis erteilen, um Anhänge herunterzuladen"),
    "your_email_being_sent" : MessageLookupByLibrary.simpleMessage("Ihre E-Mail wird gesendet …")
  };
}
