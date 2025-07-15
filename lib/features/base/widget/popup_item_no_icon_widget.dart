
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class PopupItemNoIconWidget extends StatelessWidget {

  final String _nameAction;
  final String? svgIconSelected;
  final bool isSelected;
  final double? maxWidth;
  final TextStyle? styleName;
  final EdgeInsets? padding;
  final VoidCallback? onCallbackAction;

  const PopupItemNoIconWidget(
    this._nameAction,
    {
      Key? key,
      this.isSelected = false,
      this.svgIconSelected,
      this.maxWidth,
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SizedBox(
            width: maxWidth,
            child: Row(children: [
              Expanded(child: Text(
                _nameAction,
                style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.normal
                )
              )),
              if (isSelected && svgIconSelected != null)
                ...[
                  const SizedBox(width: 12),
                  SvgPicture.asset(
                    svgIconSelected!,
                    width: 24,
                    height: 24,
                    fit: BoxFit.fill
                  ),
                ]
            ]),
          ),
        )
      )
    );
  }
}