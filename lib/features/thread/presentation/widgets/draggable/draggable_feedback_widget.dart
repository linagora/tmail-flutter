
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DraggableFeedbackWidget extends StatelessWidget {

  final String icon;
  final String title;

  const DraggableFeedbackWidget({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Material(
        clipBehavior: Clip.hardEdge,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: AppColor.colorTextButton,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SvgPicture.asset(
                icon,
                width: 24,
                height: 24,
                fit: BoxFit.fill,
                colorFilter: Colors.white.asFilter(),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
