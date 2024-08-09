import 'package:html/parser.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:tmail_ui_user/features/public_asset/presentation/public_asset_controller.dart';

extension StringToPublicAssetExtension on String {
  List<PublicAssetId> get publicAssetIdsFromHtmlContent {
    final document = parse(this);
    final images = document
      .querySelectorAll('img[public-asset-id]')
      .where((element) => element.attributes['public-asset-id'] != null);
    return images
      .map((element) => Id(element.attributes['public-asset-id']!))
      .toList();
  }
}