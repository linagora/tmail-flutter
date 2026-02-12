import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../cupertino.dart';

abstract class _BaseData<T> {
  _BaseData({
    this.items,
    this.selectedItemBuilder,
    this.value,
    this.itemHeight,
    this.hint,
    this.onChanged,
    this.onTap,
  });

  final List<DropdownMenuItem<T>>? items;
  final List<Widget> Function(BuildContext context)? selectedItemBuilder;
  final T? value;
  final double? itemHeight;
  final Widget? hint;
  final void Function(T? value)? onChanged;
  final VoidCallback? onTap;
}

class MaterialDropdownButtonData<T> extends _BaseData<T> {
  MaterialDropdownButtonData({
    super.items,
    super.selectedItemBuilder,
    super.value,
    super.itemHeight,
    super.hint,
    super.onChanged,
    this.disabledHint,
    super.onTap,
    this.elevation,
    this.style,
    this.underline,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize,
    this.isDense,
    this.isExpanded,
    this.focusColor,
    this.focusNode,
    this.autofocus,
    this.dropdownColor,
    this.menuMaxHeight,
  });

  final Widget? disabledHint;
  final int? elevation;
  final TextStyle? style;
  final Widget? underline;
  final Widget? icon;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final double? iconSize;
  final bool? isDense;
  final bool? isExpanded;
  final Color? focusColor;
  final FocusNode? focusNode;
  final bool? autofocus;
  final Color? dropdownColor;
  final double? menuMaxHeight;
}

class CupertinoDropdownButtonData<T> extends _BaseData<T> {
  CupertinoDropdownButtonData(
      {super.items,
      super.selectedItemBuilder,
      super.value,
      super.itemHeight,
      super.hint,
      super.onChanged,
      super.onTap,
      this.width,
      this.height});

  final double? width;
  final double? height;
}

/// A platform aware DropdownButton
class PlatformDropdownButton<T> extends StatelessWidget {
  const PlatformDropdownButton({
    Key? key,
    required this.items,
    this.selectedItemBuilder,
    this.value,
    this.hint,
    this.onChanged,
    this.itemHeight,
    this.onTap,
    this.material,
    this.cupertino,
  }) : super(key: key);

  final List<DropdownMenuItem<T>>? items;
  final List<Widget> Function(BuildContext context)? selectedItemBuilder;
  final T? value;
  final double? itemHeight;
  final Widget? hint;
  final void Function(T? value)? onChanged;
  final VoidCallback? onTap;

  final PlatformBuilder<MaterialDropdownButtonData<T>>? material;
  final PlatformBuilder<CupertinoDropdownButtonData<T>>? cupertino;

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) {
        final data = material?.call(context, platform);

        return DropdownButton<T>(
          items: data?.items ?? items ?? <DropdownMenuItem<T>>[],
          selectedItemBuilder: data?.selectedItemBuilder ?? selectedItemBuilder,
          value: data?.value ?? value,
          hint: data?.hint ?? hint,
          onChanged: data?.onChanged ?? onChanged,
          itemHeight:
              data?.itemHeight ?? itemHeight ?? kMinInteractiveDimension,
          disabledHint: data?.disabledHint,
          onTap: data?.onTap ?? onTap,
          elevation: data?.elevation ?? 8,
          style: data?.style,
          underline: data?.underline,
          icon: data?.icon,
          iconDisabledColor: data?.iconDisabledColor,
          iconEnabledColor: data?.iconEnabledColor,
          iconSize: data?.iconSize ?? 24.0,
          isDense: data?.isDense ?? false,
          isExpanded: data?.isExpanded ?? false,
          focusColor: data?.focusColor,
          focusNode: data?.focusNode,
          autofocus: data?.autofocus ?? false,
          dropdownColor: data?.dropdownColor,
          menuMaxHeight: data?.menuMaxHeight,
        );
      },
      cupertino: (context, platform) {
        final data = cupertino?.call(context, platform);

        return CupertinoDropdownButton(
          items: data?.items ?? items,
          selectedItemBuilder: data?.selectedItemBuilder ?? selectedItemBuilder,
          value: data?.value ?? value,
          itemExtent: data?.itemHeight ?? itemHeight ?? 12.0,
          hint: data?.hint ?? hint,
          onChanged: data?.onChanged ?? onChanged,
          width: data?.width,
          height: data?.height,
          onTap: data?.onTap ?? onTap,
        );
      },
    );
  }
}
