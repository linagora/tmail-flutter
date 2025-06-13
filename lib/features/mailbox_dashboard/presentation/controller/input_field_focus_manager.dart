
import 'package:flutter/material.dart';

class InputFieldFocusManager {

  late FocusNode fromFieldFocusNode;
  late FocusNode toFieldFocusNode;
  late FocusNode subjectFieldFocusNode;
  late FocusNode hasKeywordFieldFocusNode;
  late FocusNode notKeywordFieldFocusNode;
  late FocusNode mailboxFieldFocusNode;
  late FocusNode attachmentCheckboxFocusNode;

  InputFieldFocusManager() {
    fromFieldFocusNode = FocusNode();
    toFieldFocusNode = FocusNode();
    subjectFieldFocusNode = FocusNode();
    hasKeywordFieldFocusNode = FocusNode();
    notKeywordFieldFocusNode = FocusNode();
    mailboxFieldFocusNode = FocusNode();
    attachmentCheckboxFocusNode = FocusNode();
  }

  factory InputFieldFocusManager.initial() {
    return InputFieldFocusManager();
  }

  void dispose() {
    fromFieldFocusNode.dispose();
    toFieldFocusNode.dispose();
    subjectFieldFocusNode.dispose();
    hasKeywordFieldFocusNode.dispose();
    notKeywordFieldFocusNode.dispose();
    mailboxFieldFocusNode.dispose();
    attachmentCheckboxFocusNode.dispose();
  }
}