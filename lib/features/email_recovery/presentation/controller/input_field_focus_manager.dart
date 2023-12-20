import 'package:flutter/material.dart';

class InputFieldFocusManager {
  late FocusNode subjectFieldFocusNode;
  late FocusNode recipientsFieldFocusNode;
  late FocusNode senderFieldFocusNode;
  late FocusNode attachmentCheckboxFocusNode;

  InputFieldFocusManager() {
    subjectFieldFocusNode = FocusNode();
    recipientsFieldFocusNode = FocusNode();
    senderFieldFocusNode = FocusNode();
    attachmentCheckboxFocusNode = FocusNode();
  }

  factory InputFieldFocusManager.initial() {
    return InputFieldFocusManager();
  }

  void dispose() {
    subjectFieldFocusNode.dispose();
    recipientsFieldFocusNode.dispose();
    senderFieldFocusNode.dispose();
    attachmentCheckboxFocusNode.dispose();
  }
}