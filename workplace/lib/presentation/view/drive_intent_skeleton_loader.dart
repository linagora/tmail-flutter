import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../model/drive_intent_image_assets.dart';

/// Static, non-interactive placeholder shown over the Drive intent
/// webview/iframe while the real page is loading. Mirrors the Twake Drive
/// dialog's own loading-state design (flat grey blocks, no shimmer — the
/// reference design has none) rather than a generic spinner.
class DriveIntentSkeletonLoader extends StatelessWidget {
  final bool mobile;
  final DriveIntentImageAssets imageAssets;
  final TMailButtonWidget? closeButton;

  const DriveIntentSkeletonLoader.table({super.key, required this.imageAssets, this.closeButton})
      : mobile = false;
  const DriveIntentSkeletonLoader.list({super.key, required this.imageAssets, this.closeButton})
      : mobile = true;

  static const Color _rectColor = Color(0xFFE0E0E0);
  static const Color _dividerColor = Color(0x1F424244);
  static const Color _searchBarBg = Color(0xFFF3F6F9);
  static const int _rowCount = 6;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      child: mobile ? _buildMobile(context) : _buildWeb(),
    );
  }

  Widget _buildWeb() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                imageAssets.driveLogo,
                width: 169,
                height: 28,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _rect(width: 244, height: 32),
                  const Spacer(),
                  _searchBarPlaceholder(),
                  const SizedBox(width: 16),
                  _rect(width: 30, height: 30, radius: 7),
                  const SizedBox(width: 8),
                  _rect(width: 30, height: 30, radius: 7),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _rect(width: 51, height: 16),
                  const SizedBox(width: 8),
                  _rect(width: 25, height: 16),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                _tableHeaderRow(),
                _divider(),
                for (var i = 0; i < _rowCount; i++) ...[
                  _tableDataRow(),
                  _divider(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tableHeaderRow() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Expanded(child: SizedBox(height: 48)),
            _tableHeaderCell(width: 83, height: 19),
            _tableHeaderCell(width: 30, height: 19),
          ],
        ),
      );

  Widget _tableHeaderCell({required double width, required double height}) =>
      SizedBox(
        width: 156,
        height: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _rect(width: width, height: height),
          ),
        ),
      );

  Widget _tableDataRow() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: Row(
                  children: [
                    _rect(width: 20, height: 20, radius: 4),
                    const SizedBox(width: 12),
                    _rect(width: 124, height: 20),
                  ],
                ),
              ),
            ),
            _tableValueCell(width: 86, height: 20),
            _tableValueCell(width: 86, height: 20),
          ],
        ),
      );

  Widget _tableValueCell({required double width, required double height}) =>
      SizedBox(
        width: 156,
        height: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _rect(width: width, height: height),
          ),
        ),
      );

  Widget _buildMobile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SvgPicture.asset(
                  imageAssets.driveLogo,
                  alignment: Alignment.centerLeft,
                  width: 169,
                  height: 28,
                ),
              ),
              ?closeButton,
            ],
          ),
          const SizedBox(height: 16),
          _searchBarPlaceholder(fillWidth: true),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  for (var i = 0; i < _rowCount; i++) ...[
                    _cardRow(),
                    if (i != _rowCount - 1) const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardRow() => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _rect(width: 40, height: 40, radius: 10),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.7,
                  child: _rect(height: 14),
                ),
                const SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 0.4,
                  child: _rect(height: 12),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _searchBarPlaceholder({bool fillWidth = false}) => Container(
        width: fillWidth ? null : 262,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: _searchBarBg,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            TMailButtonWidget.fromIcon(
              icon: imageAssets.searchIcon,
              iconColor: const Color(0xFF424244).withValues(alpha: 0.4),
              backgroundColor: Colors.transparent,
              hoverColor: Colors.transparent,
              padding: const EdgeInsets.all(8),
            ),
          ],
        ),
      );

  Widget _divider() => Container(height: 1, color: _dividerColor);

  Widget _rect({
    double? width,
    required double height,
    double radius = 6,
  }) =>
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _rectColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}
