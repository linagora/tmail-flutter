
import 'package:flutter/material.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/draggable_email_data.dart';

typedef OnClickOpenMailboxAction = void Function(PresentationMailbox);
typedef OnClickOpenMenuMailboxAction = void Function(RelativeRect, PresentationMailbox);
typedef OnSelectMailboxAction = void Function(PresentationMailbox);
typedef OnDragEmailToMailboxAccepted = void Function(DraggableEmailData, PresentationMailbox);
typedef OnLongPressMailboxAction = void Function(PresentationMailbox);

typedef OnClickExpandMailboxNodeAction = void Function(MailboxNode);
typedef OnClickOpenMailboxNodeAction = void Function(MailboxNode);
typedef OnSelectMailboxNodeAction = void Function(MailboxNode);
typedef OnClickOpenMenuMailboxNodeAction = void Function(RelativeRect, MailboxNode);
typedef OnLongPressMailboxNodeAction = void Function(MailboxNode);
typedef OnClickSubscribeMailboxAction = void Function(MailboxNode);
typedef OnEmptyMailboxActionCallback = void Function(MailboxNode);