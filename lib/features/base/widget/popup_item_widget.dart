
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class PopupItemWidget extends StatelessWidget {

  final String _iconAction;
  final String _nameAction;
  final Color? colorIcon;
  final double? iconSize;
  final TextStyle? styleName;
  final EdgeInsets? padding;
  final VoidCallback? onCallbackAction;

  const PopupItemWidget(
    this._iconAction,
    this._nameAction,
    {
      Key? key,
      this.colorIcon,
      this.iconSize,
      this.styleName,
      this.padding,
      this.onCallbackAction
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: InkWell(
        onTap: onCallbackAction,
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SizedBox(
            child: Row(children: [
              SvgPicture.asset(
                _iconAction,
                width: iconSize ?? 20,
                height: iconSize ?? 20,
                fit: BoxFit.fill,
                colorFilter: colorIcon.asFilter()
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(
                _nameAction,
                style: styleName ?? const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.normal,
                  color: Colors.black
                )
              )),
            ])
          ),
        )
      ),
    );
  }
}