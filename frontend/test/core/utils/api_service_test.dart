import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:frontend/core/utils/api_service.dart';
import 'package:frontend/core/utils/failure.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late ApiService apiService;
  late MockHttpClient mockClient;

  setUp(() {
    mockClient = MockHttpClient();
    apiService = ApiService(client: mockClient, debugCurl: false);
  });

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://localhost'));
  });

  group('GET', () {
    test('should return parsed data on 200', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
        (_) async => http.Response(
          jsonEncode({'id': '1', 'name': 'Test'}),
          200,
        ),
      );

      final result = await apiService.get(
        '/test',
        (data) => data['name'] as String,
        requiresAuth: false,
      );

      expect(result.isRight(), true);
      expect(result.right, 'Test');
    });

    test('should return ServerFailure on 500', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
        (_) async => http.Response(
          jsonEncode({'message': 'Internal error'}),
          500,
        ),
      );

      final result = await apiService.get(
        '/test',
        (data) => data,
        requiresAuth: false,
      );

      expect(result.isLeft(), true);
      expect(result.left, isA<ServerFailure>());
      expect((result.left as ServerFailure).statusCode, 500);
      expect(result.left?.message, 'Internal error');
    });

    test('should return NetworkFailure on ClientException', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(http.ClientException('Connection refused'));

      final result = await apiService.get(
        '/test',
        (data) => data,
        requiresAuth: false,
      );

      expect(result.isLeft(), true);
      expect(result.left, isA<NetworkFailure>());
    });

    test('should include Authorization header when token is set', () async {
      apiService.setAccessToken('my_token');

      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
        (_) async => http.Response(jsonEncode({}), 200),
      );

      await apiService.get('/test', (data) => data);

      final captured = verify(
        () => mockClient.get(any(), headers: captureAny(named: 'headers')),
      ).captured.last as Map<String, String>;

      expect(captured['Authorization'], 'Bearer my_token');
    });

    test('should not include Authorization header after clearAccessToken', () async {
      apiService.setAccessToken('my_token');
      apiService.clearAccessToken();

      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
        (_) async => http.Response(jsonEncode({}), 200),
      );

      await apiService.get('/test', (data) => data);

      final captured = verify(
        () => mockClient.get(any(), headers: captureAny(named: 'headers')),
      ).captured.last as Map<String, String>;

      expect(captured.containsKey('Authorization'), false);
    });
  });

  group('POST', () {
    test('should return parsed data on 201', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
        (_) async => http.Response(
          jsonEncode({'id': '1', 'title': 'Created'}),
          201,
        ),
      );

      final result = await apiService.post(
        '/test',
        {'title': 'New'},
        (data) => data['title'] as String,
      );

      expect(result.isRight(), true);
      expect(result.right, 'Created');
    });

    test('should return ServerFailure on 400', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
        (_) async => http.Response(
          jsonEncode({'message': 'Bad request'}),
          400,
        ),
      );

      final result = await apiService.post(
        '/test',
        {'bad': 'data'},
        (data) => data,
      );

      expect(result.isLeft(), true);
      expect(result.left?.message, 'Bad request');
    });
  });

  group('PUT', () {
    test('should return parsed data on 200', () async {
      when(() => mockClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
        (_) async => http.Response(
          jsonEncode({'id': '1', 'title': 'Updated'}),
          200,
        ),
      );

      final result = await apiService.put(
        '/test/1',
        {'title': 'Updated'},
        (data) => data['title'] as String,
      );

      expect(result.isRight(), true);
      expect(result.right, 'Updated');
    });
  });

  group('DELETE', () {
    test('should return success on 200 with empty body', () async {
      when(() => mockClient.delete(any(), headers: any(named: 'headers')))
          .thenAnswer(
        (_) async => http.Response('', 200),
      );

      final result = await apiService.delete(
        '/test/1',
        (_) {},
        requiresAuth: false,
      );

      expect(result.isRight(), true);
    });

    test('should return ServerFailure on 404', () async {
      when(() => mockClient.delete(any(), headers: any(named: 'headers')))
          .thenAnswer(
        (_) async => http.Response(
          jsonEncode({'message': 'Not found'}),
          404,
        ),
      );

      final result = await apiService.delete(
        '/test/999',
        (_) {},
        requiresAuth: false,
      );

      expect(result.isLeft(), true);
      expect((result.left as ServerFailure).statusCode, 404);
    });
  });

  group('error message extraction', () {
    test('should extract "message" field from error response', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
        (_) async => http.Response(
          jsonEncode({'message': 'Custom error'}),
          400,
        ),
      );

      final result = await apiService.get(
        '/test',
        (data) => data,
        requiresAuth: false,
      );

      expect(result.left?.message, 'Custom error');
    });

    test('should extract "error" field if "message" is absent', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
        (_) async => http.Response(
          jsonEncode({'error': 'Error field'}),
          400,
        ),
      );

      final result = await apiService.get(
        '/test',
        (data) => data,
        requiresAuth: false,
      );

      expect(result.left?.message, 'Error field');
    });

    test('should fallback to "An error occurred" for non-JSON body', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
        (_) async => http.Response('Not JSON', 500),
      );

      final result = await apiService.get(
        '/test',
        (data) => data,
        requiresAuth: false,
      );

      expect(result.left?.message, 'An error occurred');
    });
  });
}
