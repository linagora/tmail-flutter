import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/base/widget/text_input_decoration_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ApplicativeTokenField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final AppLocalizations appLocalizations;
  final ImagePaths? imagePath;

  const ApplicativeTokenField({
    Key? key,
    required this.onChanged,
    required this.appLocalizations,
    this.imagePath,
  }) : super(key: key);

  @override
  State<ApplicativeTokenField> createState() => _ApplicativeTokenFieldState();
}

class _ApplicativeTokenFieldState extends State<ApplicativeTokenField> with SingleTickerProviderStateMixin {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  late final AnimationController rotationController;

  @override
  void initState() {
    super.initState();
    rotationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.appLocalizations.advancedSettings),
      controlAffinity: ListTileControlAffinity.leading,
      leading: widget.imagePath == null
        ? null
        : RotationTransition(
            turns: Tween(begin: 0.0, end: 0.5).animate(rotationController),
            child: SvgPicture.asset(
              widget.imagePath!.icArrowDown,
              width: 24,
              height: 24,
              fit: BoxFit.fill,
            ),
          ),
      shape: const Border(),
      tilePadding: const EdgeInsets.symmetric(horizontal: 32),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 32),
      onExpansionChanged: (isExpanded) {
        if (isExpanded) {
          rotationController.forward();
        } else {
          rotationController.reverse();
        }
      },
      children: [
        Row(
          children: [
            Text(
              widget.appLocalizations.applicativeToken,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFieldBuilder(
                controller: controller,
                focusNode: focusNode,
                autoFocus: true,
                onTextChange: widget.onChanged,
                maxLines: 1,
                decoration: TextInputDecorationBuilder().build(),
              ),
            ),
          ],
        ),
        Text(widget.appLocalizations.someJMAPServicesDoNotSupportLoginViaPassword),
      ],
    );
  }
}
