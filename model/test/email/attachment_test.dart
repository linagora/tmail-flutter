import 'package:flutter_test/flutter_test.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:model/email/attachment.dart';

void main() {
  final accountId = AccountId(Id('1'));
  const baseDownloadUrl = 'http://localhost/download/{accountId}/{blobId}/{name}?name={name}&type={type}';

  group('attachment test:', () {
    group('getDownloadUrl:', () {
      test(
        'should return download url with blobId, name and type',
      () {
        // arrange
        final attachment = Attachment(
          blobId: Id('some-blob-id'),
          name: 'some-name',
          type: MediaType.parse('application/octet-stream'),
        );
        
        // act
        final result = attachment.getDownloadUrl(baseDownloadUrl, accountId);
        
        // assert
        expect(result, 'http://localhost/download/1/some-blob-id/some-name?name=some-name&type=application%2Foctet-stream');
      });

      test(
        'should return download url with blobId, name and type '
        'when attachment name contains question mark character',
      () {
        // arrange
        final attachment = Attachment(
          blobId: Id('some-blob-id'),
          name: 'some-name?',
          type: MediaType.parse('application/octet-stream'),
        );
        
        // act
        final result = attachment.getDownloadUrl(baseDownloadUrl, accountId);
        
        // assert
        expect(result, 'http://localhost/download/1/some-blob-id/some-name%3F?name=some-name%3F&type=application%2Foctet-stream');
      });

      test(
        'should return download url with blobId, name and type '
        'when attachment name is Vietnamese',
      () {
        // arrange
        final attachment = Attachment(
          blobId: Id('some-blob-id'),
          name: 'tiêu đề attachment',
          type: MediaType.parse('application/octet-stream'),
        );
        
        // act
        final result = attachment.getDownloadUrl(baseDownloadUrl, accountId);
        
        // assert
        expect(result, 'http://localhost/download/1/some-blob-id/ti%C3%AAu%20%C4%91%E1%BB%81%20attachment?name=ti%C3%AAu%20%C4%91%E1%BB%81%20attachment&type=application%2Foctet-stream');
      });
    });
  });
}