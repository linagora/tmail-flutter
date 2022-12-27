import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identities_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/widgets/signature_of_identity_builder.dart';

import 'identity_list_tile_builder.dart';

class IdentitiesRadioListBuilder extends StatefulWidget {
  const IdentitiesRadioListBuilder({
    Key? key, 
    required this.controller,
  }) : super(key: key);

  final IdentitiesController controller;

  @override
  State<StatefulWidget> createState() => _IdentitiesRadioListBuilderState();
}

class _IdentitiesRadioListBuilderState extends State<IdentitiesRadioListBuilder> {
  late final controller = widget.controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.listAllIdentities.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: AppColor.colorBorderIdentityInfo, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        ),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              key: const Key('identities_checkbox_list'),
              height: 256,
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [0, 0.5, 0.55, 0.60, 0.65, 0.70, 0.75, 0.80, 0.85, 0.90, 1].map((e) 
                        => Colors.white.withOpacity(e.toDouble())).toList(),
                    stops: const [0.8, 0.82, 0.84, 0.86, 0.88, 0.90, 0.92, 0.94, 0.96, 0.98, 1],// Gradient from https://learnui.design/tools/gradient-generator.html
                    tileMode: TileMode.mirror,
                  ),
                border: controller.isSignatureShow() ? const Border(bottom: BorderSide(color: AppColor.colorBorderIdentityInfo)): null,
              ),
              padding: const EdgeInsets.only(left: 12.0, bottom: 12.0, top: 12.0, right: 4.0),
              child: Scrollbar(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(right: 12.0),
                    itemCount: controller.listAllIdentities.value.length,
                    itemBuilder: ((context, index) {
                      return IdentityListTileBuilder(
                        controller: widget.controller,
                        index: index,
                        selected: widget.controller.selectedIndex.value,
                      );
                    }),
                  )
                ),
              ),
            ),
            if(controller.isSignatureShow())
              Obx(() => SignatureOfIdentityBuilder(identity: controller.identitySelected.value!)),
          ],
        ),
      ));
    });
  }
}