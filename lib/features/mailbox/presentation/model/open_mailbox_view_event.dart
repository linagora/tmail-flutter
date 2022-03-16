import 'package:core/presentation/state/success.dart';
import 'package:flutter/widgets.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class OpenMailboxViewEvent extends ViewEvent {
  final BuildContext buildContext;
  final PresentationMailbox presentationMailbox;

  OpenMailboxViewEvent(this.buildContext, this.presentationMailbox);

  @override
  List<Object?> get props => [buildContext, presentationMailbox];
}