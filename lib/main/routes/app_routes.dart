abstract class AppRoutes {
  static const HOME = '/';
  static const LOGIN = '/login';
  static const MAILBOX = '$MAILBOX_DASHBOARD/mailbox';
  static const MAILBOX_DASHBOARD = '/mailboxDashBoard';
  static const THREAD = '$MAILBOX_DASHBOARD/thread';
  static const EMAIL = '$THREAD/email';
  static const SESSION = '/session';
  static const COMPOSER = '/composer';
  static const DESTINATION_PICKER = '/destinationPicker';
  static const MAILBOX_CREATOR = '$MAILBOX_DASHBOARD/mailboxCreator';
  static const MANAGE_ACCOUNT = '$MAILBOX_DASHBOARD/manage_account';
  static const IDENTITY_CREATOR = '$MANAGE_ACCOUNT/identity_creator';
  static const RULES_FILTER_CREATOR = '$MANAGE_ACCOUNT/rules_filter_creator';
  static const EMAILS_FORWARD_CREATOR = '$MANAGE_ACCOUNT/emails_forward_creator';
  static const SEARCH_EMAIL = '$MAILBOX_DASHBOARD/search_email';
  static const CONTACT = '$MAILBOX_DASHBOARD/contact';
}