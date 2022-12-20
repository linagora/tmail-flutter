import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tmail_ui_user/features/session/domain/repository/session_repository.dart';
import 'package:tmail_ui_user/features/session/domain/state/get_session_state.dart';

class GetSessionInteractor {
  final SessionRepository sessionRepository;

  GetSessionInteractor(this.sessionRepository);

  Future<Either<Failure, Success>> execute() async {
    log(
        'GetSessionInteractor::execute(): execute: test' );
    try {
      // Failure
      final dio = Dio();
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody:  true));
      try {
        var request = await dio.post('https://jmap.linagora.com/jmap',
            data: {
              "using": ["urn:ietf:params:jmap:core", "urn:ietf:params:jmap:mail"],
              "methodCalls": [
                [
                  "Email/query",
                  {
                    "accountId":
                    "2871cff2a1fdca653db3eb30876ea938778bb39cb0dc525ac5fe101ce8da9432",
                    "filter": {"from": "ttnn"},
                    "sort": [
                      {"isAscending": false, "property": "receivedAt"}
                    ],
                    "limit": 20
                  },
                  "c0"
                ],
                [
                  "Email/get",
                  {
                    "accountId":
                    "2871cff2a1fdca653db3eb30876ea938778bb39cb0dc525ac5fe101ce8da9432",
                    "#ids": {
                      "resultOf": "c0",
                      "name": "Email/query",
                      "path": "/ids/*"
                    },
                    "properties": [
                      "id",
                      "subject",
                      "from",
                      "to",
                      "cc",
                      "bcc",
                      "keywords",
                      "size",
                      "receivedAt",
                      "sentAt",
                      "preview",
                      "hasAttachment",
                      "replyTo",
                      "mailboxIds"
                    ]
                  },
                  "c1"
                ]
              ]
            },
            options: Options(headers: {
              'accept': 'application/json;jmapVersion=rfc-8621',
              'content-type': 'application/json',
              'Authorization': 'Basic dG1uZ3V5ZW5AbGluYWdvcmEuY29tOk1hbmhAMTk5Njcy'
            }));
        if (request.statusCode == 200) {
          print(request.data);
        } else {
          print(request.data);
        }
      } catch (e) {
        log(
            'GetSessionInteractor::execute(): execute: $e' );
        print(e);
      }
      log(
          'GetSessionInteractor::execute(): execute: finish' );
      final session = await sessionRepository.getSession();

      return Right<Failure, Success>(GetSessionSuccess(session));
    } catch (e) {
      log(
          'GetSessionInteractor::execute(): execute2: $e' );
      return Left<Failure, Success>(GetSessionFailure(e));
    }
  }
}