import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

import '../../integration_test/utils/jmap_query_recorder.dart';

List<String> _lines = [];

// debugPrintSynchronously writes through print, so capture it in a zone.
List<String> _dump() {
  _lines = [];
  runZoned(
    JmapQueryRecorder.instance.dump,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) => _lines.add(line),
    ),
  );
  return _lines;
}

Map<String, dynamic> _request(String method, Map<String, dynamic> args) => {
      'using': ['urn:ietf:params:jmap:mail'],
      'methodCalls': [
        [method, args, 'c0'],
      ],
    };

Map<String, dynamic> _response(String method, Map<String, dynamic> args) => {
      'methodResponses': [
        [method, args, 'c0'],
      ],
    };

void _recordsFilterAndResultCount() {
  JmapQueryRecorder.instance.recordRequest(_request('Email/query', {
    'filter': {'hasKeyword': 'label-1'},
  }));
  JmapQueryRecorder.instance.recordResponse(_response('Email/query', {
    'ids': ['a', 'b'],
    'total': 2,
  }));

  final lines = _dump();

  expect(lines, hasLength(2));
  expect(lines[0], contains('[EMAIL QUERY] 0'));
  expect(lines[0], contains('request filter={"hasKeyword":"label-1"}'));
  expect(lines[1], contains('response ids=2 total=2'));
}

void _ignoresOtherMethods() {
  JmapQueryRecorder.instance.recordRequest(_request('Email/get', {'ids': ['a']}));
  JmapQueryRecorder.instance.recordResponse(_response('Mailbox/get', {'list': []}));

  expect(_dump(), isEmpty);
}

void _survivesUnserializableAndMalformedBodies() {
  JmapQueryRecorder.instance.recordRequest(_request('Email/query', {'filter': Object()}));
  JmapQueryRecorder.instance.recordRequest('not a map');
  JmapQueryRecorder.instance.recordResponse(null);

  final lines = _dump();

  expect(lines, hasLength(1));
  expect(lines.single, contains("request filter=\"Instance of 'Object'\""));
}

void _keepsOnlyTheLast20Entries() {
  for (var i = 0; i < 30; i++) {
    JmapQueryRecorder.instance.recordResponse(_response('Email/query', {'ids': [], 'total': i}));
  }

  final lines = _dump();

  expect(lines, hasLength(20));
  expect(lines.first, contains('total=10'));
  expect(lines.last, contains('total=29'));
}

void _tagsResponseWithItsRequestSeq() {
  JmapQueryRecorder.instance.recordRequest(_request('Email/query', {
    'filter': {'hasKeyword': 'label-1'},
  }), seq: 7);
  JmapQueryRecorder.instance.recordResponse({
    'methodResponses': [
      ['Email/query', {'ids': ['a']}, 'c0'],
      ['Email/get', {'list': [{}], 'notFound': []}, 'c1'],
    ],
  }, seq: 7);

  final lines = _dump();

  expect(lines, hasLength(3));
  expect(lines[0], contains('#7 request'));
  expect(lines[1], contains('#7 response ids=1'));
  expect(lines[2], contains('#7 get list=1 notFound=0'));
}

void _skipsResponsesOfUnrecordedRequests() {
  JmapQueryRecorder.instance.recordResponse(_response('Email/query', {'ids': []}), seq: 3);

  expect(_dump(), isEmpty);
}

void _recordsFailedQueryRequests() {
  JmapQueryRecorder.instance.recordRequest(_request('Email/query', {'filter': {}}), seq: 2);
  JmapQueryRecorder.instance.recordError(2, 'cancel status=null');
  JmapQueryRecorder.instance.recordError(9, 'x');

  final lines = _dump();

  expect(lines, hasLength(2));
  expect(lines.last, contains('#2 failed cancel status=null'));
}

void _ignoresLateResponseAcrossReattach() {
  Get.put(Dio());
  addTearDown(() => Get.delete<Dio>());
  final recorder = JmapQueryRecorder.instance..attach();
  final optionsA = RequestOptions(data: _request('Email/query', {'filter': {'a': 1}}));
  recorder.onRequest(optionsA, RequestInterceptorHandler());
  recorder.detach();
  recorder.attach();
  final optionsB = RequestOptions(data: _request('Email/query', {'filter': {'b': 1}}));
  recorder.onRequest(optionsB, RequestInterceptorHandler());
  recorder.onResponse(
    Response(requestOptions: optionsA, data: _response('Email/query', {'ids': ['a1', 'a2', 'a3']})),
    ResponseInterceptorHandler(),
  );
  recorder.onResponse(
    Response(requestOptions: optionsB, data: _response('Email/query', {'ids': ['b1']})),
    ResponseInterceptorHandler(),
  );

  final lines = _dump();

  expect(lines, hasLength(2));
  expect(lines[0], contains('#2 request filter={"b":1}'));
  expect(lines[1], contains('#2 response ids=1'));
}

void _ignoresResponseOfRequestSentBeforeAttach() {
  Get.put(Dio());
  addTearDown(() => Get.delete<Dio>());
  final recorder = JmapQueryRecorder.instance..attach();
  // Never passed through onRequest, so it carries no seq.
  final options = RequestOptions(data: _request('Email/query', {'filter': {'a': 1}}));
  recorder.onResponse(
    Response(requestOptions: options, data: _response('Email/query', {'ids': ['a1']})),
    ResponseInterceptorHandler(),
  );

  expect(_dump(), isEmpty);
}

void main() {
  setUp(JmapQueryRecorder.instance.detach);
  test('ignores a late response across reattach', _ignoresLateResponseAcrossReattach);
  test('ignores a response to a request sent before attach', _ignoresResponseOfRequestSentBeforeAttach);

  test('records the filter and the result count of Email/query', _recordsFilterAndResultCount);
  test('ignores methods other than Email/query', _ignoresOtherMethods);
  test('survives unserializable and malformed bodies', _survivesUnserializableAndMalformedBodies);
  test('keeps only the last 20 entries', _keepsOnlyTheLast20Entries);
  test('tags a response with its request seq', _tagsResponseWithItsRequestSeq);
  test('skips responses of unrecorded requests', _skipsResponsesOfUnrecordedRequests);
  test('records failed query requests', _recordsFailedQueryRequests);
}
