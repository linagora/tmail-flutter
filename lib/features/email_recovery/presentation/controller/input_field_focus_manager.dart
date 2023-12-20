import 'package:flutter/material.dart';

class InputFieldFocusManager {
  late FocusNode deletionDateFieldFocusNode;
  late FocusNode receptionDateFieldFocusNode;
  late FocusNode subjectFieldFocusNode;
  late FocusNode recipientsFieldFocusNode;
  late FocusNode senderFieldFocusNode;
  late FocusNode attachmentCheckboxFocusNode;
  late FocusNode createButtonFocusNode;

  InputFieldFocusManager() {
    deletionDateFieldFocusNode = FocusNode();
    receptionDateFieldFocusNode = FocusNode();
    subjectFieldFocusNode = FocusNode();
    recipientsFieldFocusNode = FocusNode();
    senderFieldFocusNode = FocusNode();
    attachmentCheckboxFocusNode = FocusNode(skipTraversal: true);
    createButtonFocusNode = FocusNode();
  }

  factory InputFieldFocusManager.initial() {
    return InputFieldFocusManager();
  }

  void dispose() {
    deletionDateFieldFocusNode.dispose();
    receptionDateFieldFocusNode.dispose();
    subjectFieldFocusNode.dispose();
    recipientsFieldFocusNode.dispose();
    senderFieldFocusNode.dispose();
    attachmentCheckboxFocusNode.dispose();
    createButtonFocusNode.dispose();
  }
}