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
    return Intl.message('Team Mail',
        name: 'login_text_slogan');
  }

  String get prefix_https {
    return Intl.message('https://',
        name: 'prefix_https');
  }

  String get email {
    return Intl.message('email',
        name: 'email');
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
      'No emails in this mailbox',
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

  String get your_email_being_sent {
    return Intl.message(
      'Your email being sent...',
      name: 'your_email_being_sent',
    );
  }

  String get message_dialog_send_email_without_recipient {
    return Intl.message(
      'Your email should have at least one recipient',
      name: 'message_dialog_send_email_without_recipient',
    );
  }

  String count_email_selected(int count) {
    return Intl.message(
        '$count selected',
        name: 'count_email_selected',
        args: [count]
    );
  }

  String get mark_as_unread {
    return Intl.message(
      'Mark as unread',
      name: 'mark_as_unread',
    );
  }

  String get mark_as_read {
    return Intl.message(
      'Mark as read',
      name: 'mark_as_read',
    );
  }

  String get move_to_trash {
    return Intl.message(
      'Move to trash',
      name: 'move_to_trash',
    );
  }

  String get mark_as_starred {
    return Intl.message(
      'Mark as starred',
      name: 'mark_as_starred',
    );
  }

  String get move_to_spam {
    return Intl.message(
      'Move to spam',
      name: 'move_to_spam',
    );
  }

  String marked_multiple_item_as_read(int count) {
    return Intl.message(
        'Marked $count item as read',
        name: 'marked_multiple_item_as_read',
        args: [count]
    );
  }

  String marked_multiple_item_as_unread(int count) {
    return Intl.message(
        'Marked $count item as unread',
        name: 'marked_multiple_item_as_unread',
        args: [count]
    );
  }

  String get an_error_occurred {
    return Intl.message(
      'Error! An error occurred. Please try again later.',
      name: 'an_error_occurred',
    );
  }

  String get attachment_download_failed {
    return Intl.message(
      'Attachment download failed',
      name: 'attachment_download_failed',
    );
  }

  String downloading_file(String fileName) {
    return Intl.message(
      'Downloading $fileName',
      name: 'downloading_file',
      args: [fileName]
    );
  }

  String get preparing_to_export {
    return Intl.message(
      'Preparing to export',
      name: 'preparing_to_export'
    );
  }

  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel'
    );
  }

  String get user_cancel_download_file {
    return Intl.message(
      'User cancel download file',
      name: 'user_cancel_download_file'
    );
  }

  String get you_need_to_grant_files_permission_to_download_attachments {
    return Intl.message(
      'You need to grant files permission to download attachments',
      name: 'you_need_to_grant_files_permission_to_download_attachments'
    );
  }

  String count_attachment(int count) {
    return Intl.message(
        '$count attachments',
        name: 'count_attachment',
        args: [count]
    );
  }

  String get attach_file_prepare_text {
    return Intl.message(
      'Preparing to attach file...',
      name: 'attach_file_prepare_text'
    );
  }

  String get can_not_upload_this_file_as_attachments {
    return Intl.message(
      'Can not upload this file as attachments',
      name: 'can_not_upload_this_file_as_attachments'
    );
  }

  String get attachments_uploaded_successfully {
    return Intl.message(
      'Attachments uploaded successfully',
      name: 'attachments_uploaded_successfully'
    );
  }

  String get pick_attachments {
    return Intl.message(
      'Pick attachments',
      name: 'pick_attachments'
    );
  }

  String get photos_and_videos {
    return Intl.message(
      'Photos and Videos',
      name: 'photos_and_videos',
    );
  }

  String get browse {
    return Intl.message(
      'Browse',
      name: 'browse',
    );
  }

  String moved_to_mailbox(String destinationMailboxPath) {
    return Intl.message(
        'Moved to $destinationMailboxPath',
        name: 'moved_to_mailbox',
        args: [destinationMailboxPath]
    );
  }

  String get undo_action {
    return Intl.message(
        'UNDO',
        name: 'undo_action'
    );
  }

  String marked_star_multiple_item(int count) {
    return Intl.message(
        'Marked star $count item',
        name: 'marked_star_multiple_item',
        args: [count]
    );
  }

  String marked_unstar_multiple_item(int count) {
    return Intl.message(
        'Marked unstar $count item',
        name: 'marked_unstar_multiple_item',
        args: [count]
    );
  }

  String get search_mail {
    return Intl.message(
      'Search mail',
      name: 'search_mail',
    );
  }

  String get prefix_suggestion_search {
    return Intl.message(
      'Search for',
      name: 'prefix_suggestion_search',
    );
  }

  String get no_emails_matching_your_search {
    return Intl.message(
      'No emails are matching your search',
      name: 'no_emails_matching_your_search',
    );
  }

  String get results {
    return Intl.message(
      'Results',
      name: 'results',
    );
  }

  String get edit {
    return Intl.message('Edit',
        name: 'edit');
  }

  String get hint_search_emails {
    return Intl.message(
        'Search for emails and files',
        name: 'hint_search_emails');
  }

  String get compose {
    return Intl.message(
        'Compose',
        name: 'compose');
  }

  String get delete {
    return Intl.message(
        'Delete',
        name: 'delete');
  }

  String get move {
    return Intl.message(
        'Move',
        name: 'move');
  }

  String get spam {
    return Intl.message(
        'Spam',
        name: 'spam');
  }

  String get flag {
    return Intl.message(
        'Flag',
        name: 'flag');
  }

  String get read {
    return Intl.message(
        'Read',
        name: 'read');
  }

  String get unread {
    return Intl.message(
        'Unread',
        name: 'unread');
  }

  String get the_feature_is_under_development {
    return Intl.message(
        'This feature is under development.',
        name: 'the_feature_is_under_development');
  }

  String marked_message_toast(String action) {
    return Intl.message(
        'You’ve marked messages as "$action"',
        name: 'marked_message_toast',
        args: [action]
    );
  }

  String get folders {
    return Intl.message(
        'Folders',
        name: 'folders'
    );
  }

  String get logout {
    return Intl.message('Logout',
        name: 'logout');
  }

  String get hint_search_mailboxes {
    return Intl.message(
        'Search mailboxes',
        name: 'hint_search_mailboxes');
  }

  String get with_attachments {
    return Intl.message(
        'With attachments',
        name: 'with_attachments'
    );
  }

  String get starred {
    return Intl.message(
        'Starred',
        name: 'starred'
    );
  }

  String filter_message_toast(String filterOption) {
    return Intl.message(
        'You’ve filtered messages by "$filterOption"',
        name: 'filter_message_toast',
        args: [filterOption]
    );
  }

  String get disable_filter_message_toast {
    return Intl.message(
        'You’ve disabled filtered messages',
        name: 'disable_filter_message_toast'
    );
  }

  String get with_unread {
    return Intl.message(
        'With Unread',
        name: 'with_unread');
  }

  String get with_starred {
    return Intl.message(
        'With Starred',
        name: 'with_starred');
  }

  String get message_has_been_sent_successfully {
    return Intl.message(
      'Message has been sent successfully',
      name: 'message_has_been_sent_successfully',
    );
  }

  String get message_has_been_sent_failure {
    return Intl.message(
      'Message has been sent failure',
      name: 'message_has_been_sent_failure',
    );
  }

  String get done {
    return Intl.message(
        'Done',
        name: 'done'
    );
  }

  String get new_mailbox {
    return Intl.message(
      'New mailbox',
      name: 'new_mailbox',
    );
  }

  String get mailbox_location {
    return Intl.message(
      'Mailbox location',
      name: 'mailbox_location',
    );
  }

  String get default_mailbox {
    return Intl.message(
      'Default mailbox',
      name: 'default_mailbox',
    );
  }

  String get name_of_mailbox_is_required {
    return Intl.message(
      'Name of mailbox is required',
      name: 'name_of_mailbox_is_required',
    );
  }

  String get mailbox_name_cannot_contain_special_characters {
    return Intl.message(
      'Mailbox name cannot contain special characters',
      name: 'mailbox_name_cannot_contain_special_characters',
    );
  }

  String get this_folder_name_is_already_taken {
    return Intl.message(
      'This folder name is already taken',
      name: 'this_folder_name_is_already_taken',
    );
  }

  String new_mailbox_is_created(String nameMailbox) {
    return Intl.message(
        '$nameMailbox is created',
        name: 'new_mailbox_is_created',
        args: [nameMailbox]
    );
  }

  String get create_new_mailbox_failure {
    return Intl.message(
        'Create new mailbox failure',
        name: 'create_new_mailbox_failure'
    );
  }

  String get drafts_saved {
    return Intl.message(
      'Draft saved',
      name: 'drafts_saved',
    );
  }

  String get discard {
    return Intl.message(
        'Discard',
        name: 'discard'
    );
  }

  String get hint_input_create_new_mailbox {
    return Intl.message(
        'Enter name of mailbox',
        name: 'hint_input_create_new_mailbox'
    );
  }

  String get rename {
    return Intl.message(
        'Rename',
        name: 'rename');
  }

  String get delete_mailboxes_successfully {
    return Intl.message(
        'Delete mailboxes successfully',
        name: 'delete_mailboxes_successfully');
  }

  String get delete_mailboxes_failure {
    return Intl.message(
        'Delete mailboxes failure',
        name: 'delete_mailboxes_failure');
  }

  String get delete_mailboxes {
    return Intl.message(
        'Delete mailboxes',
        name: 'delete_mailboxes');
  }

  String message_confirmation_dialog_delete_mailbox(String nameMailbox) {
    return Intl.message(
        '"$nameMailbox" mailbox and all of the sub-folders and messages it contains will be deleted and won\'t be able to recover. Do you want to continue to delete?',
        name: 'message_confirmation_dialog_delete_mailbox',
        args: [nameMailbox]
    );
  }

  String get rename_mailbox {
    return Intl.message(
        'Rename mailbox',
        name: 'rename_mailbox');
  }

  String get this_field_cannot_be_blank {
    return Intl.message(
      'This field cannot be blank',
      name: 'this_field_cannot_be_blank',
    );
  }

  String get there_is_already_folder_with_the_same_name {
    return Intl.message(
      'There is already folder with the same name',
      name: 'there_is_already_folder_with_the_same_name',
    );
  }

  String get email_address_is_not_in_the_correct_format {
    return Intl.message(
      'Email address is not in the correct format',
      name: 'email_address_is_not_in_the_correct_format',
    );
  }

  String get preparing_to_save {
    return Intl.message(
        'Preparing to save',
        name: 'preparing_to_save'
    );
  }

  String get new_message {
    return Intl.message(
      'New message',
      name: 'new_message',
    );
  }

  String get details {
    return Intl.message(
        'Details',
        name: 'details');
  }

  String get hide {
    return Intl.message(
        'Hide',
        name: 'hide');
  }

  String get copy_email_address {
    return Intl.message(
        'Copy email address',
        name: 'copy_email_address');
  }

  String get compose_email {
    return Intl.message(
        'Compose email',
        name: 'compose_email');
  }

  String get email_address_copied_to_clipboard {
    return Intl.message(
        'Email address copied to clipboard',
        name: 'email_address_copied_to_clipboard');
  }

  String get minimize {
    return Intl.message(
        'Minimize',
        name: 'minimize');
  }

  String get fullscreen {
    return Intl.message(
        'Fullscreen',
        name: 'fullscreen');
  }

  String get close {
    return Intl.message(
        'Close',
        name: 'close');
  }

  String get send {
    return Intl.message(
        'Send',
        name: 'send');
  }

  String get attachments {
    return Intl.message(
        'Attachments',
        name: 'attachments');
  }

  String get show_all {
    return Intl.message(
        'Show all',
        name: 'show_all');
  }

  String get message_dialog_send_email_without_a_subject {
    return Intl.message(
        'Are you sure to send messages without a subject?',
        name: 'message_dialog_send_email_without_a_subject');
  }

  String get app_name {
    return Intl.message(
        'Tmail',
        name: 'app_name');
  }

  String get search_emails {
    return Intl.message(
        'Search emails',
        name: 'search_emails');
  }

  String get select_all {
    return Intl.message(
      'Select all',
      name: 'select_all',
    );
  }

  String get mark_all_as_read {
    return Intl.message(
      'Mark all as read',
      name: 'mark_all_as_read',
    );
  }

  String get filter_messages {
    return Intl.message(
      'Filter messages',
      name: 'filter_messages',
    );
  }

  String get not_starred {
    return Intl.message(
        'Not starred',
        name: 'not_starred'
    );
  }

  String get select {
    return Intl.message(
      'Select',
      name: 'select',
    );
  }

  String get more {
    return Intl.message(
      'More',
      name: 'more',
    );
  }

  String get back {
    return Intl.message(
      'Back',
      name: 'back',
    );
  }

  String get expand {
    return Intl.message(
        'Expand',
        name: 'expand');
  }

  String get collapse {
    return Intl.message(
        'Collapse',
        name: 'collapse');
  }

  String get save_to_drafts {
    return Intl.message(
      'Save to drafts',
      name: 'save_to_drafts',
    );
  }

  String get hint_compose_email {
    return Intl.message(
        'Start composing a letter...',
        name: 'hint_compose_email');
  }

  String get attach_file {
    return Intl.message(
        'Attach file',
        name: 'attach_file');
  }

  String get show {
    return Intl.message(
        'Show',
        name: 'show');
  }

  String get add_recipients {
    return Intl.message(
        'Add recipients',
        name: 'add_recipients');
  }

  String get sending_failed {
    return Intl.message(
        'Sending failed',
        name: 'sending_failed');
  }

  String get send_anyway {
    return Intl.message(
        'Send anyway',
        name: 'send_anyway');
  }

  String get empty_subject {
    return Intl.message(
        'Empty subject',
        name: 'empty_subject');
  }

  String get message_dialog_send_email_with_email_address_invalid {
    return Intl.message(
        'Check the correctness of email addresses and try again',
        name: 'message_dialog_send_email_with_email_address_invalid');
  }

  String get fix_email_addresses {
    return Intl.message(
        'Fix email addresses',
        name: 'fix_email_addresses');
  }

  String get your_download_has_started {
    return Intl.message(
        'Your download has started',
        name: 'your_download_has_started'
    );
  }

  String get moved_to_trash {
    return Intl.message(
        'Moved to Trash',
        name: 'moved_to_trash'
    );
  }

  String get no_internet_connection {
    return Intl.message(
        'No internet connection',
        name: 'no_internet_connection'
    );
  }

  String get page_name {
    return Intl.message(
        'Team - Mail',
        name: 'page_name');
  }

  String get message_delete_all_email_in_trash_button {
    return Intl.message(
        'All messages in Trash will be deleted if you reach limited storage.',
        name: 'message_delete_all_email_in_trash_button');
  }

  String get empty_trash_now {
    return Intl.message(
        'Empty trash now',
        name: 'empty_trash_now');
  }

  String get empty_trash_folder {
    return Intl.message(
        'Empty trash folder',
        name: 'empty_trash_folder');
  }

  String get empty_trash_dialog_message {
    return Intl.message(
        'You are about to permanently delete all items in Trash . Do you want to continue?',
        name: 'empty_trash_dialog_message');
  }

  String get delete_all {
    return Intl.message(
        'Delete all',
        name: 'delete_all');
  }

  String toast_message_delete_multiple_email_permanently_success(int count) {
    return Intl.message(
        '$count Messages has been deleted forever',
        name: 'toast_message_delete_multiple_email_permanently_success',
        args: [count]);
  }

  String get toast_message_delete_a_email_permanently_success {
    return Intl.message(
        'Message has been deleted forever',
        name: 'toast_message_delete_a_email_permanently_success');
  }

  String get delete_permanently {
    return Intl.message(
        'Delete permanently',
        name: 'delete_permanently');
  }

  String get delete_messages_forever {
    return Intl.message(
        'Delete messages forever',
        name: 'delete_messages_forever');
  }

  String get delete_message_forever {
    return Intl.message(
        'Delete message forever',
        name: 'delete_message_forever');
  }

  String delete_multiple_messages_dialog(int count) {
    return Intl.message(
        'You are about to permanently delete $count items in Trash . Do you want to continue?',
        name: 'delete_multiple_messages_dialog',
        args: [count]);
  }

  String get delete_single_message_dialog {
    return Intl.message(
        'You are about to permanently delete this message. Do you want to continue?',
        name: 'delete_single_message_dialog');
  }

  String get toast_message_empty_trash_folder_success {
    return Intl.message(
        'All messages has been deleted forever',
        name: 'toast_message_empty_trash_folder_success');
  }

  String get version {
    return Intl.message(
        'Version',
        name: 'version');
  }

  String message_dialog_send_email_exceeds_maximum_size(String maxSize) {
    return Intl.message(
        'Your message could not be sent because it exceeds the maximum size of $maxSize',
        name: 'message_dialog_send_email_exceeds_maximum_size',
        args: [maxSize]
    );
  }

  String message_dialog_upload_attachments_exceeds_maximum_size(String maxSize) {
    return Intl.message(
        'You have reached the maximum file size. Please upload files that total size is less than $maxSize',
        name: 'message_dialog_upload_attachments_exceeds_maximum_size',
        args: [maxSize]
    );
  }

  String get got_it {
    return Intl.message(
        'Got it',
        name: 'got_it');
  }

  String get maximum_files_size {
    return Intl.message(
        'Maximum files size',
        name: 'maximum_files_size');
  }

  String get exchange {
    return Intl.message(
        'Exchange',
        name: 'exchange'
    );
  }

  String get move_message {
    return Intl.message(
      'Move message',
      name: 'move_message',
    );
  }

  String get forwarded_message {
    return Intl.message(
      'Forwarded message',
      name: 'forwarded_message',
    );
  }

  String get date {
    return Intl.message(
      'Date',
      name: 'date',
    );
  }

  String get mark_as_spam {
    return Intl.message(
      'Mark as spam',
      name: 'mark_as_spam',
    );
  }

  String get remove_from_spam {
    return Intl.message(
      'Remove from spam',
      name: 'remove_from_spam',
    );
  }

  String get marked_as_spam {
    return Intl.message(
      'Marked as spam',
      name: 'marked_as_spam',
    );
  }

  String get marked_as_not_spam {
    return Intl.message(
      'Marked as not spam',
      name: 'marked_as_not_spam',
    );
  }

  String get star {
    return Intl.message(
      'Star',
      name: 'star',
    );
  }

  String get un_star {
    return Intl.message(
      'Unstar',
      name: 'un_star',
    );
  }

  String get un_spam {
    return Intl.message(
      'Unspam',
      name: 'un_spam',
    );
  }
}