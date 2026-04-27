import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/core/utils/either.dart';

class ApiService {
  final http.Client client;
  String? _accessToken;
  final bool _debugCurl;

  ApiService({required this.client, bool debugCurl = false})
    : _debugCurl = debugCurl;

  void setAccessToken(String token) {
    _accessToken = token;
  }

  void clearAccessToken() {
    _accessToken = null;
  }

  void _printCurlCommand({
    required String method,
    required String url,
    required Map<String, String> headers,
    String? body,
  }) {
    if (!_debugCurl) return;

    final StringBuffer curlCommand = StringBuffer('curl -X $method');
    debugPrint('\n\n----------------------------------------\n\n');

    // Add headers
    headers.forEach((key, value) {
      curlCommand.write(" -H '$key: $value'");
    });

    // Add body if present
    if (body != null && body.isNotEmpty) {
      curlCommand.write(" -d '$body'");
    }

    curlCommand.write(" '$url'");

    debugPrint('🔍 CURL Command:');
    debugPrint(curlCommand.toString());
    debugPrint('\n\n----------------------------------------\n\n');
  }

  Map<String, String> _getHeaders({bool requiresAuth = true}) {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (requiresAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  Future<Either<Failure, T>> _handleRequest<T>(
    Future<http.Response> Function() request,
    T Function(dynamic) parser,
  ) async {
    try {
      final response = await request();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return Either.right(parser(null));
        }
        final decoded = jsonDecode(response.body);
        return Either.right(parser(decoded));
      } else {
        final errorMessage = _extractErrorMessage(response);
        return Either.left(
          ServerFailure(message: errorMessage, statusCode: response.statusCode),
        );
      }
    } on http.ClientException catch (e) {
      return Either.left(NetworkFailure(message: e.message));
    } catch (e) {
      return Either.left(ServerFailure(message: e.toString()));
    }
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      return decoded['message'] ?? decoded['error'] ?? 'An error occurred';
    } catch (_) {
      return 'An error occurred';
    }
  }

  Future<Either<Failure, T>> get<T>(
    String endpoint,
    T Function(dynamic) parser, {
    bool requiresAuth = true,
  }) {
    final url = '${ApiConstants.baseUrl}$endpoint';
    final headers = _getHeaders(requiresAuth: requiresAuth);

    _printCurlCommand(method: 'GET', url: url, headers: headers);

    return _handleRequest(
      () => client.get(Uri.parse(url), headers: headers),
      parser,
    );
  }

  Future<Either<Failure, T>> post<T>(
    String endpoint,
    Map<String, dynamic> body,
    T Function(dynamic) parser, {
    bool requiresAuth = false,
  }) {
    final url = '${ApiConstants.baseUrl}$endpoint';
    final headers = _getHeaders(requiresAuth: requiresAuth);
    final encodedBody = jsonEncode(body);

    _printCurlCommand(
      method: 'POST',
      url: url,
      headers: headers,
      body: encodedBody,
    );

    return _handleRequest(
      () => client.post(Uri.parse(url), headers: headers, body: encodedBody),
      parser,
    );
  }

  Future<Either<Failure, T>> put<T>(
    String endpoint,
    Map<String, dynamic> body,
    T Function(dynamic) parser, {
    bool requiresAuth = true,
  }) {
    final url = '${ApiConstants.baseUrl}$endpoint';
    final headers = _getHeaders(requiresAuth: requiresAuth);
    final encodedBody = jsonEncode(body);

    _printCurlCommand(
      method: 'PUT',
      url: url,
      headers: headers,
      body: encodedBody,
    );

    return _handleRequest(
      () => client.put(Uri.parse(url), headers: headers, body: encodedBody),
      parser,
    );
  }

  Future<Either<Failure, T>> delete<T>(
    String endpoint,
    T Function(dynamic) parser, {
    bool requiresAuth = true,
  }) {
    final url = '${ApiConstants.baseUrl}$endpoint';
    final headers = _getHeaders(requiresAuth: requiresAuth);

    _printCurlCommand(method: 'DELETE', url: url, headers: headers);

    return _handleRequest(
      () => client.delete(Uri.parse(url), headers: headers),
      parser,
    );
  }
}
