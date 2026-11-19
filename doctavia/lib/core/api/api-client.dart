import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:doctavia/core/services/service-storage.dart';

/// A utility class to log API requests and responses in a readable format.
class ApiLogger {
  static void logRequest(String method, Uri uri, {Map<String, String>? headers, Object? body}) {
    if (kReleaseMode) return;

    debugPrint('+----------------------------------------------------------------------------');
    debugPrint('▶ API REQUEST: $method');
    debugPrint('  URL: ${uri.toString()}');

    if (headers != null && headers.isNotEmpty) {
      debugPrint('  HEADERS:');
      headers.forEach((key, value) {
        debugPrint('    $key: $value');
      });
    }

    if (body != null) {
      debugPrint('  BODY: <hidden>');
    }
    debugPrint('+----------------------------------------------------------------------------');
  }

  static void logResponse(http.Response response, {Duration? duration}) {
    if (kReleaseMode) return;

    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    final emoji = isSuccess ? '✅' : '❌';

    debugPrint('+----------------------------------------------------------------------------');
    debugPrint('$emoji API RESPONSE [${response.statusCode}]');
    debugPrint('  URL: ${response.request?.url.toString() ?? 'unknown'}');
    if (duration != null) {
      debugPrint('  DURATION: ${duration.inMilliseconds}ms');
    }
    if (response.body.isNotEmpty) {
      debugPrint('  BODY SIZE: ${response.bodyBytes.length} bytes');
    }
    debugPrint('+----------------------------------------------------------------------------');
  }

  static void logError(String method, Uri uri, Object error, {StackTrace? stackTrace}) {
    if (kReleaseMode) return;

    debugPrint('+----------------------------------------------------------------------------');
    debugPrint('❌ API ERROR: $method');
    debugPrint('  URL: ${uri.toString()}');
    debugPrint('  MESSAGE: $error');
    if (stackTrace != null) {
      debugPrint('  STACKTRACE:');
      stackTrace.toString().split('\n').take(10).forEach((line) => debugPrint('    $line'));
    }
    debugPrint('+----------------------------------------------------------------------------');
  }
}

/// Typed exception for API errors.
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Centralized HTTP client that auto-injects JWT and handles errors.
class ApiClient {
  // Persistent Ngrok Static URL
  static const String _baseUrl = 'https://curvy-channel-politely.ngrok-free.dev/api/v1';

  final StorageService _storage;
  VoidCallback? onUnauthorized;

  ApiClient(this._storage);

  /// Public getter for the base URL (used by screens that build full file URLs).
  String get baseUrl => _baseUrl;

  /// Build standard headers, injecting the Bearer token if present.
  Future<Map<String, String>> _headers() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      // Required by ngrok free tier to bypass the warning interstitial
      'ngrok-skip-browser-warning': 'true',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Decode and handle the response. Throws [ApiException] on non-2xx.
  dynamic _handleResponse(http.Response response, {Duration? duration}) {
    ApiLogger.logResponse(response, duration: duration);

    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (e) {
        // Not JSON, or malformed
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body == null && response.body.isNotEmpty) {
        throw ApiException(
          'Invalid JSON response from server',
          response.statusCode,
        );
      }
      return body;
    }

    if (response.statusCode == 401) {
      onUnauthorized?.call();
    }

    // Extract the error message from the backend's standard shape
    final errorMsg = (body is Map)
        ? (body['error']?['message'] ?? body['message'])
        : null;
    throw ApiException(
      errorMsg ?? 'Server returned error [${response.statusCode}]',
      response.statusCode,
    );
  }

  // --- HTTP Verbs -----------------------------------------------

  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse(
      '$_baseUrl$path',
    ).replace(queryParameters: queryParams);
    final headers = await _headers();
    ApiLogger.logRequest('GET', uri, headers: headers);

    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.get(uri, headers: headers);
      stopwatch.stop();
      return _handleResponse(response, duration: stopwatch.elapsed);
    } catch (e, stack) {
      ApiLogger.logError('GET', uri, e, stackTrace: stack);
      rethrow;
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = await _headers();
    ApiLogger.logRequest('POST', uri, headers: headers, body: body);

    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      stopwatch.stop();
      return _handleResponse(response, duration: stopwatch.elapsed);
    } catch (e, stack) {
      ApiLogger.logError('POST', uri, e, stackTrace: stack);
      rethrow;
    }
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = await _headers();
    ApiLogger.logRequest('PUT', uri, headers: headers, body: body);

    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      stopwatch.stop();
      return _handleResponse(response, duration: stopwatch.elapsed);
    } catch (e, stack) {
      ApiLogger.logError('PUT', uri, e, stackTrace: stack);
      rethrow;
    }
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = await _headers();
    ApiLogger.logRequest('PATCH', uri, headers: headers, body: body);

    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.patch(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      stopwatch.stop();
      return _handleResponse(response, duration: stopwatch.elapsed);
    } catch (e, stack) {
      ApiLogger.logError('PATCH', uri, e, stackTrace: stack);
      rethrow;
    }
  }

  Future<dynamic> delete(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = await _headers();
    ApiLogger.logRequest('DELETE', uri, headers: headers);

    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.delete(uri, headers: headers);
      stopwatch.stop();
      return _handleResponse(response, duration: stopwatch.elapsed);
    } catch (e, stack) {
      ApiLogger.logError('DELETE', uri, e, stackTrace: stack);
      rethrow;
    }
  }

  Future<dynamic> multipart(
    String path, {
    required String method,
    Map<String, String>? fields,
    http.MultipartFile? file,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    
    final request = http.MultipartRequest(method, uri);
    final commonHeaders = await _headers();
    request.headers.addAll(commonHeaders);
    
    if (fields != null) {
      request.fields.addAll(fields);
    }
    
    if (file != null) {
      request.files.add(file);
    }

    ApiLogger.logRequest(method, uri, headers: request.headers, body: fields);

    final stopwatch = Stopwatch()..start();
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      stopwatch.stop();
      return _handleResponse(response, duration: stopwatch.elapsed);
    } catch (e, stack) {
      ApiLogger.logError(method, uri, e, stackTrace: stack);
      rethrow;
    }
  }
}
