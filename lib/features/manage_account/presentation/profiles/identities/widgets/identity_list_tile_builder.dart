import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identities_controller.dart';

class IdentityListTileBuilder extends StatelessWidget {
  const IdentityListTileBuilder({
    Key? key, 
    required this.controller,
    required this.index,
    required this.selected
  }) : super(key: key);

  final IdentitiesController controller;
  final int index;
  final int? selected;

  @override
  Widget build(BuildContext context) {
    final imagePaths = controller.imagePaths;
    final listAllIdentities = controller.listAllIdentities.value;
    final identity = listAllIdentities[index];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () => controller.selectIdentity(index),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: isIdentitySelected(index) ? AppColor.colorItemSelected : Colors.transparent,
          ),
          padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, right: 12.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: BuildUtils.isWeb ? 8.0 : 0.0),
                child: Radio<int>(
                  value: index,
                  groupValue: selected,
                  onChanged: (selectedValue) => controller.selectIdentity(index),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      identity.name ?? '', 
                      overflow: CommonTextStyle.defaultTextOverFlow,
                      softWrap: CommonTextStyle.defaultSoftWrap, 
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.black)),
                    _buildIconWithTextLine(imagePaths.icEmail, identity.email),
                    for(final widget in _buildReplyLines(identity, imagePaths))
                      widget
                  ],  
                )
              ),
              if(isIdentitySelected(index))...[
                buildSVGIconButton(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                  icon: imagePaths.icEdit, 
                  iconSize: 24,
                  iconColor: AppColor.primaryColor, 
                  onTap: () => controller.goToEditIdentity(context, controller.identitySelected.value!),
                ),
                buildSVGIconButton(
                  padding: const EdgeInsets.only(right: 0.0),
                  icon: imagePaths.icDeleteOutline,
                  iconSize: 24,
                  iconColor: AppColor.colorActionDeleteConfirmDialog, 
                  onTap: () => controller.openConfirmationDialogDeleteIdentityAction(context, controller.identitySelected.value!),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildReplyLines(Identity? identity, ImagePaths imagePaths) {
    return [
      for(var identityReplyTo in identity?.replyTo?.toList() ?? [])
        _buildIconWithTextLine(imagePaths.icReply, identityReplyTo.email)];
  }

  Widget _buildIconWithTextLine(String imagePath, String? text) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: SvgPicture.asset(
            imagePath, 
            color: AppColor.primaryColor, 
            width: 16,
            fit: BoxFit.fitHeight,
        )),
        // replacement character after ..., so wrap it inside richtext is workaround solution
        Expanded(child: Text(
          text ?? '',  style: const TextStyle(
            color: AppColor.colorEmailAddressFull,
            fontWeight: FontWeight.w400,
            fontSize: 13,
          ),
          overflow: CommonTextStyle.defaultTextOverFlow,
          softWrap: CommonTextStyle.defaultSoftWrap,
        )),
      ]
    );
  }

  bool isIdentitySelected(int index) {
    return index == selected;
  }
}