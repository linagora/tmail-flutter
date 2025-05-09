
import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';

typedef OnClickOpenMailboxAction = void Function(PresentationMailbox);
typedef OnClickOpenMenuMailboxAction = void Function(RelativeRect, PresentationMailbox);
typedef OnSelectMailboxAction = void Function(PresentationMailbox);
typedef OnDragEmailToMailboxAccepted = void Function(List<PresentationEmail>, PresentationMailbox);
typedef OnLongPressMailboxAction = void Function(PresentationMailbox);

typedef OnClickExpandMailboxNodeAction = void Function(MailboxNode, GlobalKey itemKey);
typedef OnClickOpenMailboxNodeAction = void Function(MailboxNode);
typedef OnSelectMailboxNodeAction = void Function(MailboxNode);
typedef OnClickOpenMenuMailboxNodeAction = void Function(RelativeRect, MailboxNode);
typedef OnLongPressMailboxNodeAction = void Function(MailboxNode);
typedef OnClickSubscribeMailboxAction = void Function(MailboxNode);
typedef OnEmptyMailboxActionCallback = void Function(MailboxNode);