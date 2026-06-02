import 'package:drive_attachment/drive_attachment/data/datasource/drive_attachment_datasource.dart';
import 'package:drive_attachment/drive_attachment/domain/entity/drive_intent.dart';
import 'package:drive_attachment/drive_attachment/domain/repository/drive_attachment_repository.dart';

class DriveAttachmentRepositoryImpl implements DriveAttachmentRepository {
  final DriveAttachmentDataSource _dataSource;

  DriveAttachmentRepositoryImpl(this._dataSource);

  @override
  Future<DriveIntent> createIntent(Uri platformUrl, String accessToken) =>
      _dataSource.createIntent(platformUrl, accessToken);

  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) =>
      _dataSource.exchangeToken(platformUrl, oidcIdToken);
}
