import 'package:flutter/material.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';

typedef OnOpenLabelContextMenuAction = Future<void> Function(
  Label label,
  RelativeRect position,
);

typedef OnLabelActionTypeCallback = void Function(
  Label label,
  LabelActionType actionType,
);

typedef OnLongPressLabelItemAction = void Function(Label label);