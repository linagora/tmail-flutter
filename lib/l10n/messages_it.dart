// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it locale. All the
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
  String get localeName => 'it';

  static m0(count) => "${count} allegati";

  static m1(count) => "${count} selezionato";

  static m12(count) => "Stai per eliminare definitivamente ${count} elementi nel Cestino . Vuoi continuare?";

  static m2(fileName) => "Scarica di ${fileName}";

  static m9(filterOption) => "Hai filtrato i messaggi per \"${filterOption}\"";

  static m3(sentDate, emailAddress) => "Il ${sentDate}, da ${emailAddress}";

  static m10(action) => "Hai contrassegnato i messaggi come \"${action}\"";

  static m4(count) => "Elemento ${count} contrassegnato come letto";

  static m5(count) => "Elemento ${count} contrassegnato come non letto";

  static m6(count) => "${count} elemento contrassegnato preferito";

  static m7(count) => "${count} elemento rimosso dal preferito";

  static m13(nameMailbox) => "La casella di posta «${nameMailbox}» e tutte le sottocartelle e i messaggi contenuti verranno eliminati e non sarà possibile ripristinarli. Vuoi continuare a eliminare?";

  static m8(destinationMailboxPath) => "Spostato in ${destinationMailboxPath}";

  static m11(nameMailbox) => "${nameMailbox} è stato creato";

  static m14(count) => "${count} messaggi sono stati eliminati per sempre";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function> {
    "add_recipients" : MessageLookupByLibrary.simpleMessage("Aggiungi destinatari"),
    "an_error_occurred" : MessageLookupByLibrary.simpleMessage("Errore! Si è verificato un errore. Si prega di riprovare più tardi."),
    "app_name" : MessageLookupByLibrary.simpleMessage("Tmail"),
    "attach_file" : MessageLookupByLibrary.simpleMessage("Allega un file"),
    "attach_file_prepare_text" : MessageLookupByLibrary.simpleMessage("Preparazione per allegare file..."),
    "attachment_download_failed" : MessageLookupByLibrary.simpleMessage("Download degli allegati non riuscito"),
    "attachments" : MessageLookupByLibrary.simpleMessage("Allegati"),
    "attachments_uploaded_successfully" : MessageLookupByLibrary.simpleMessage("Allegati caricati con successo"),
    "back" : MessageLookupByLibrary.simpleMessage("Indietro"),
    "bcc_email_address_prefix" : MessageLookupByLibrary.simpleMessage("Bcc"),
    "browse" : MessageLookupByLibrary.simpleMessage("Sfoglia"),
    "can_not_upload_this_file_as_attachments" : MessageLookupByLibrary.simpleMessage("Non è possibile caricare questo file come allegato"),
    "cancel" : MessageLookupByLibrary.simpleMessage("Cancella"),
    "cc_email_address_prefix" : MessageLookupByLibrary.simpleMessage("Cc"),
    "close" : MessageLookupByLibrary.simpleMessage("Chiudi"),
    "collapse" : MessageLookupByLibrary.simpleMessage("Ridurre"),
    "compose" : MessageLookupByLibrary.simpleMessage("Componi"),
    "compose_email" : MessageLookupByLibrary.simpleMessage("Componi email"),
    "copy_email_address" : MessageLookupByLibrary.simpleMessage("Copia l\'indirizzo email"),
    "count_attachment" : m0,
    "count_email_selected" : m1,
    "create_new_mailbox_failure" : MessageLookupByLibrary.simpleMessage("Impossibile creare una nuova casella di posta"),
    "default_mailbox" : MessageLookupByLibrary.simpleMessage("Casella di posta predefinita"),
    "delete" : MessageLookupByLibrary.simpleMessage("Elimina"),
    "delete_all" : MessageLookupByLibrary.simpleMessage("Elimina tutti"),
    "delete_mailboxes" : MessageLookupByLibrary.simpleMessage("Elimina le caselle di posta"),
    "delete_mailboxes_failure" : MessageLookupByLibrary.simpleMessage("Impossibile eliminare le caselle di posta"),
    "delete_mailboxes_successfully" : MessageLookupByLibrary.simpleMessage("Le caselle di posta eliminate con successo"),
    "delete_message_forever" : MessageLookupByLibrary.simpleMessage("Elimina i messaggi per sempre"),
    "delete_messages_forever" : MessageLookupByLibrary.simpleMessage("Elimina i messaggi per sempre"),
    "delete_multiple_messages_dialog" : m12,
    "delete_permanently" : MessageLookupByLibrary.simpleMessage("Elimina definitivamente"),
    "delete_single_message_dialog" : MessageLookupByLibrary.simpleMessage("Stai per eliminare definitivamente questo messaggio. Vuoi continuare?"),
    "details" : MessageLookupByLibrary.simpleMessage("Dettagli"),
    "disable_filter_message_toast" : MessageLookupByLibrary.simpleMessage("Hai disabilitato i messaggi filtrati"),
    "discard" : MessageLookupByLibrary.simpleMessage("Scartare"),
    "done" : MessageLookupByLibrary.simpleMessage("Fatto"),
    "downloading_file" : m2,
    "drafts_saved" : MessageLookupByLibrary.simpleMessage("Bozza salvata"),
    "edit" : MessageLookupByLibrary.simpleMessage("Modifica"),
    "email" : MessageLookupByLibrary.simpleMessage("e-mail"),
    "email_address_copied_to_clipboard" : MessageLookupByLibrary.simpleMessage("Indirizzo email copiato negli appunti"),
    "email_address_is_not_in_the_correct_format" : MessageLookupByLibrary.simpleMessage("L\'indirizzo email non è nel formato corretto"),
    "empty_subject" : MessageLookupByLibrary.simpleMessage("Soggetto vuoto"),
    "empty_trash_dialog_message" : MessageLookupByLibrary.simpleMessage("Stai per eliminare definitivamente tutti gli elementi nel Cestino. Vuoi continuare?"),
    "empty_trash_folder" : MessageLookupByLibrary.simpleMessage("Svuota la cartella del cestino"),
    "empty_trash_now" : MessageLookupByLibrary.simpleMessage("Svuota il cestino ora"),
    "expand" : MessageLookupByLibrary.simpleMessage("Espandere"),
    "filter_message_toast" : m9,
    "filter_messages" : MessageLookupByLibrary.simpleMessage("Filtra i messaggi"),
    "fix_email_addresses" : MessageLookupByLibrary.simpleMessage("Correggi gli indirizzi email"),
    "flag" : MessageLookupByLibrary.simpleMessage("Segna"),
    "folders" : MessageLookupByLibrary.simpleMessage("Cartelle"),
    "forward" : MessageLookupByLibrary.simpleMessage("Inoltrare"),
    "from_email_address_prefix" : MessageLookupByLibrary.simpleMessage("Da"),
    "fullscreen" : MessageLookupByLibrary.simpleMessage("A schermo intero"),
    "header_email_quoted" : m3,
    "hide" : MessageLookupByLibrary.simpleMessage("Nascondere"),
    "hint_compose_email" : MessageLookupByLibrary.simpleMessage("Inizia a comporre una lettera..."),
    "hint_content_email_composer" : MessageLookupByLibrary.simpleMessage("Inizia a scrivere la tua e-mail qui"),
    "hint_input_create_new_mailbox" : MessageLookupByLibrary.simpleMessage("Scegli il nome della casella di posta"),
    "hint_search_emails" : MessageLookupByLibrary.simpleMessage("Cerca email e file"),
    "hint_search_mailboxes" : MessageLookupByLibrary.simpleMessage("Cerca nelle caselle di posta"),
    "hint_text_email_address" : MessageLookupByLibrary.simpleMessage("Nome o indirizzo e-mail"),
    "initializing_data" : MessageLookupByLibrary.simpleMessage("Inizializzazione dei dati..."),
    "login" : MessageLookupByLibrary.simpleMessage("Accedi"),
    "login_text_slogan" : MessageLookupByLibrary.simpleMessage("Team Mail"),
    "mailbox_location" : MessageLookupByLibrary.simpleMessage("Posizione della casella di posta"),
    "mailbox_name_cannot_contain_special_characters" : MessageLookupByLibrary.simpleMessage("Il nome della casella do posta non può contenere caratteri speciali"),
    "mark_all_as_read" : MessageLookupByLibrary.simpleMessage("Segna tutti come letti"),
    "mark_as_read" : MessageLookupByLibrary.simpleMessage("Segna come letto"),
    "mark_as_unread" : MessageLookupByLibrary.simpleMessage("Segna come non letto"),
    "marked_message_toast" : m10,
    "marked_multiple_item_as_read" : m4,
    "marked_multiple_item_as_unread" : m5,
    "marked_star_multiple_item" : m6,
    "marked_unstar_multiple_item" : m7,
    "message_confirmation_dialog_delete_mailbox" : m13,
    "message_delete_all_email_in_trash_button" : MessageLookupByLibrary.simpleMessage("Tutti i messaggi nel Cestino verranno eliminati se raggiungi il limite dello spazio."),
    "message_dialog_send_email_with_email_address_invalid" : MessageLookupByLibrary.simpleMessage("Verifica la correttezza degli indirizzi email e riprova"),
    "message_dialog_send_email_without_a_subject" : MessageLookupByLibrary.simpleMessage("Sei sicuro di inviare messaggi senza oggetto?"),
    "message_dialog_send_email_without_recipient" : MessageLookupByLibrary.simpleMessage("La tua email deve avere almeno uno destinatario"),
    "message_has_been_sent_failure" : MessageLookupByLibrary.simpleMessage("Impossibile inviare il messaggio"),
    "message_has_been_sent_successfully" : MessageLookupByLibrary.simpleMessage("Il messaggio è stato inviato con successo"),
    "minimize" : MessageLookupByLibrary.simpleMessage("Minimizzare"),
    "more" : MessageLookupByLibrary.simpleMessage("Di più"),
    "move" : MessageLookupByLibrary.simpleMessage("Muovi"),
    "move_to_spam" : MessageLookupByLibrary.simpleMessage("Sposta nello spam"),
    "move_to_trash" : MessageLookupByLibrary.simpleMessage("Sposta nel cestino"),
    "moved_to_mailbox" : m8,
    "moved_to_trash" : MessageLookupByLibrary.simpleMessage("Spostato nel Cestino"),
    "my_folders" : MessageLookupByLibrary.simpleMessage("LE MIE CARTELLE"),
    "name_of_mailbox_is_required" : MessageLookupByLibrary.simpleMessage("Il nome della casella di posta è obbligatorio"),
    "new_folder" : MessageLookupByLibrary.simpleMessage("Nuova cartella"),
    "new_mailbox" : MessageLookupByLibrary.simpleMessage("Nuova casella di posta"),
    "new_mailbox_is_created" : m11,
    "new_message" : MessageLookupByLibrary.simpleMessage("Nuovo messaggio"),
    "no_emails" : MessageLookupByLibrary.simpleMessage("Nessuna e-mail in questa casella di posta"),
    "no_emails_matching_your_search" : MessageLookupByLibrary.simpleMessage("Nessuna e-mail corrisponde alla tua ricerca"),
    "no_internet_connection" : MessageLookupByLibrary.simpleMessage("Nessuna connessione internet"),
    "no_mail_selected" : MessageLookupByLibrary.simpleMessage("Nessuna e-mail selezionata"),
    "not_starred" : MessageLookupByLibrary.simpleMessage("Non preferiti"),
    "page_name" : MessageLookupByLibrary.simpleMessage("Team - Mail"),
    "password" : MessageLookupByLibrary.simpleMessage("password"),
    "photos_and_videos" : MessageLookupByLibrary.simpleMessage("Foto e video"),
    "pick_attachments" : MessageLookupByLibrary.simpleMessage("Scegli gli allegati"),
    "prefix_forward_email" : MessageLookupByLibrary.simpleMessage("Fwd:"),
    "prefix_https" : MessageLookupByLibrary.simpleMessage("https://"),
    "prefix_reply_email" : MessageLookupByLibrary.simpleMessage("Re:"),
    "prefix_suggestion_search" : MessageLookupByLibrary.simpleMessage("Cerca per"),
    "preparing_to_export" : MessageLookupByLibrary.simpleMessage("Preparazione per l\'esportazione"),
    "preparing_to_save" : MessageLookupByLibrary.simpleMessage("Prepariamo a salvare"),
    "read" : MessageLookupByLibrary.simpleMessage("Letto"),
    "rename" : MessageLookupByLibrary.simpleMessage("Rinomina"),
    "rename_mailbox" : MessageLookupByLibrary.simpleMessage("Rinomina la casella di posta"),
    "reply" : MessageLookupByLibrary.simpleMessage("Rispondi"),
    "reply_all" : MessageLookupByLibrary.simpleMessage("Rispondi a tutti"),
    "results" : MessageLookupByLibrary.simpleMessage("Risultati"),
    "save_to_drafts" : MessageLookupByLibrary.simpleMessage("Salva in bozze"),
    "search_emails" : MessageLookupByLibrary.simpleMessage("Cerca nelle email"),
    "search_folder" : MessageLookupByLibrary.simpleMessage("Cerca nella cartella"),
    "search_mail" : MessageLookupByLibrary.simpleMessage("Cerca nella posta"),
    "select" : MessageLookupByLibrary.simpleMessage("Selezionare"),
    "select_all" : MessageLookupByLibrary.simpleMessage("Seleziona tutti"),
    "send" : MessageLookupByLibrary.simpleMessage("Inviare"),
    "send_anyway" : MessageLookupByLibrary.simpleMessage("Inviare lo stesso"),
    "sending_failed" : MessageLookupByLibrary.simpleMessage("Invio fallito"),
    "show" : MessageLookupByLibrary.simpleMessage("Mostra"),
    "show_all" : MessageLookupByLibrary.simpleMessage("Mostra tutti"),
    "spam" : MessageLookupByLibrary.simpleMessage("Spam"),
    "starred" : MessageLookupByLibrary.simpleMessage("Preferito"),
    "storage" : MessageLookupByLibrary.simpleMessage("STOCCAGGIO"),
    "subject_email" : MessageLookupByLibrary.simpleMessage("Oggetto"),
    "the_feature_is_under_development" : MessageLookupByLibrary.simpleMessage("Questa funzione è in fase di sviluppo."),
    "there_is_already_folder_with_the_same_name" : MessageLookupByLibrary.simpleMessage("Esiste già una cartella con lo stesso nome"),
    "this_field_cannot_be_blank" : MessageLookupByLibrary.simpleMessage("Questo campo non può essere vuoto"),
    "this_folder_name_is_already_taken" : MessageLookupByLibrary.simpleMessage("Questo nome di cartella è già usato"),
    "to_email_address_prefix" : MessageLookupByLibrary.simpleMessage("A"),
    "toast_message_delete_a_email_permanently_success" : MessageLookupByLibrary.simpleMessage("Il messaggio è stato eliminato per sempre"),
    "toast_message_delete_multiple_email_permanently_success" : m14,
    "undo_action" : MessageLookupByLibrary.simpleMessage("DISFARE"),
    "unknown_error_login_message" : MessageLookupByLibrary.simpleMessage("Si è verificato un errore sconosciuto. Si prega di riprovare"),
    "unread" : MessageLookupByLibrary.simpleMessage("Non letto"),
    "unread_email_notification" : MessageLookupByLibrary.simpleMessage("nuovo"),
    "user_cancel_download_file" : MessageLookupByLibrary.simpleMessage("L\'utente annulla la scarica del file"),
    "with_attachments" : MessageLookupByLibrary.simpleMessage("Con allegati"),
    "with_starred" : MessageLookupByLibrary.simpleMessage("Con Preferiti"),
    "with_unread" : MessageLookupByLibrary.simpleMessage("Con Non letti"),
    "you_need_to_grant_files_permission_to_download_attachments" : MessageLookupByLibrary.simpleMessage("È necessario concedere ai file il permesso per scaricare gli allegati"),
    "your_download_has_started" : MessageLookupByLibrary.simpleMessage("Il tuo download è iniziato"),
    "your_email_being_sent" : MessageLookupByLibrary.simpleMessage("La tua e-mail viene inviata…")
  };
}
