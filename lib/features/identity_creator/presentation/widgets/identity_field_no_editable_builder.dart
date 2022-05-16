
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

class IdentityFieldNoEditableBuilder {

  final String _label;
  final EmailAddress? _emailAddressSelected;

  IdentityFieldNoEditableBuilder(this._label, this._emailAddressSelected);

  Widget build() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_label, style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColor.colorContentEmail)),
      const SizedBox(height: 8),
      Container(
          height: 44,
          alignment: Alignment.center,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.colorInputBorderCreateMailbox, width: 0.5),
              color: AppColor.colorInputBackgroundCreateMailbox),
          child: Text(
            _emailAddressSelected?.email ?? '',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: AppColor.colorInputBorderCreateMailbox),
            maxLines: 1,
            overflow: BuildUtils.isWeb ? null : TextOverflow.ellipsis,
          )
      ),
    ]);
  }
}