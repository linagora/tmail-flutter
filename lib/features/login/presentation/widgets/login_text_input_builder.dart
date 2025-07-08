import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/text/text_form_field_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_input_decoration_builder.dart';

typedef OnSubmitted = void Function(String);

class LoginTextInputBuilder extends StatefulWidget {
  final String? hintText;
  final String? prefixText;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final List<String>? autofillHints;
  final bool obscureText;
  final bool passwordInput;
  final ValueChanged<String>? onTextChange;
  final OnSubmitted? onSubmitted;

  const LoginTextInputBuilder({
    super.key,
    this.hintText,
    this.prefixText,
    this.textInputAction,
    this.focusNode,
    this.controller,
    this.autofillHints,
    this.onSubmitted,
    this.onTextChange,
    this.passwordInput = true,
    this.obscureText = true,
  });

  @override
  State<LoginTextInputBuilder> createState() => _LoginTextInputBuilderState();
}

class _LoginTextInputBuilderState extends State<LoginTextInputBuilder> {

  final imagePaths = Get.find<ImagePaths>();

  late TextEditingController _controller;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: [
        TextFormFieldBuilder(
          onTextSubmitted: widget.onSubmitted,
          onTextChange: widget.onTextChange,
          obscureText: _obscureText,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          controller: _controller,
          textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
            color: AppColor.loginTextFieldHintColor,
            fontSize: 16,
            fontWeight: FontWeight.normal
          ),
          focusNode: widget.focusNode,
          decoration: (LoginInputDecorationBuilder()
            ..setHintText(widget.hintText)
            ..setPrefixText(widget.prefixText)
            ..setContentPadding(const EdgeInsetsDirectional.only(
                start: 25,
                top: 15,
                bottom: 15,
                end: 40
            ))
            ..setHintStyle(ThemeUtils.defaultTextStyleInterFont.copyWith(
                color: AppColor.loginTextFieldHintColor,
                fontSize: 16,
                fontWeight: FontWeight.normal
            ))
            ..setPrefixStyle(ThemeUtils.defaultTextStyleInterFont.copyWith(
                color: AppColor.loginTextFieldHintColor,
                fontSize: 16,
                fontWeight: FontWeight.normal
            ))
            ..setErrorTextStyle(ThemeUtils.defaultTextStyleInterFont.copyWith(
                color: AppColor.loginTextFieldErrorBorder,
                fontSize: 13,
                fontWeight: FontWeight.normal
            ))
            ..setFocusBorder(const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(
                  width: 1,
                  color: AppColor.loginTextFieldFocusedBorder
                )
            ))
            ..setEnabledBorder(const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(
                  width: 1,
                  color: AppColor.loginTextFieldBorderColor
                )
            ))
            ..setErrorBorder(const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(
                  width: 1,
                  color: AppColor.loginTextFieldErrorBorder
                )
            ))
          ).build(),
        ),
        if (widget.passwordInput)
          TMailButtonWidget.fromIcon(
            icon: _obscureText ? imagePaths.icEye : imagePaths.icEyeOff,
            iconSize: 18,
            margin: const EdgeInsetsDirectional.only(end: 4),
            backgroundColor: Colors.transparent,
            onTapActionCallback: () {
              setState(() => _obscureText = !_obscureText);
            },
          )
      ]
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
}
