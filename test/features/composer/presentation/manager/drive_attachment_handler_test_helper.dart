import 'package:workplace/domain/entity/drive_document.dart';

final linkDoc = DriveDocument(
  id: '1',
  name: 'Report',
  size: 100,
  mimeType: 'application/pdf',
  sharingLink: Uri.parse('https://drive.example.com/report'),
);

final attachmentDoc = DriveDocument(
  id: '2',
  name: 'Photo.jpg',
  size: 200,
  mimeType: 'image/jpeg',
  downloadLink: Uri.parse('https://drive.example.com/photo.jpg'),
);

const noLinkDoc = DriveDocument(
  id: '3',
  name: 'Unknown',
  size: 0,
  mimeType: 'application/octet-stream',
);
