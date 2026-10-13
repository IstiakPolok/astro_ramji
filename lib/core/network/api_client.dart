import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;

  ApiException({
    required this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient({http.Client? httpClient, String? baseUrl}) {
    if (httpClient != null || baseUrl != null) {
      return ApiClient._custom(httpClient: httpClient, baseUrl: baseUrl);
    }
    return _instance;
  }
  static String cleanUrl(String url) {
    var u = url.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }

  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://catechismal-imperatorial-camren.ngrok-free.dev',
  );

  String _baseUrl;
  String? _sessionId;
  final http.Client _client;

  ApiClient._internal()
      : _client = http.Client(),
        _baseUrl = cleanUrl(_defaultBaseUrl);

  ApiClient._custom({http.Client? httpClient, String? baseUrl})
      : _client = httpClient ?? http.Client(),
        _baseUrl = cleanUrl(baseUrl ?? _defaultBaseUrl);

  String get baseUrl => _baseUrl;
  String? get sessionId => _sessionId;

  Future<void> setBaseUrl(String url) async {
    _baseUrl = cleanUrl(url);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_base_url', _baseUrl);
    } catch (e) {
      debugPrint('ApiClient: Error saving base url: $e');
    }
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sessionId = prefs.getString('api_session_id');
      final savedUrl = prefs.getString('api_base_url');
      if (savedUrl != null && savedUrl.isNotEmpty) {
        _baseUrl = cleanUrl(savedUrl);
      }
    } catch (e) {
      debugPrint('ApiClient: Error reading session or base url: $e');
    }
  }

  Future<void> setSessionId(String? sessionId) async {
    _sessionId = sessionId;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (sessionId != null) {
        await prefs.setString('api_session_id', sessionId);
      } else {
        await prefs.remove('api_session_id');
      }
    } catch (e) {
      debugPrint('ApiClient: Error persisting session: $e');
    }
  }

  Map<String, String> _buildHeaders([Map<String, String>? extraHeaders]) {
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };

    if (_sessionId != null && _sessionId!.isNotEmpty) {
      headers[HttpHeaders.cookieHeader] = 'sessionid=$_sessionId';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  void _extractCookies(http.Response response) {
    final rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      final match = RegExp(r'sessionid=([^;]+)').firstMatch(rawCookie);
      if (match != null) {
        final newSessionId = match.group(1);
        if (newSessionId != null && newSessionId != _sessionId) {
          setSessionId(newSessionId);
        }
      }
    }
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '$_baseUrl$cleanPath';

    if (queryParameters != null && queryParameters.isNotEmpty) {
      final stringParams = queryParameters.map((key, value) => MapEntry(key, value?.toString() ?? ''));
      return Uri.parse(fullUrl).replace(queryParameters: stringParams);
    }

    return Uri.parse(fullUrl);
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await _client
          .get(uri, headers: _buildHeaders(headers))
          .timeout(const Duration(seconds: 15));

      _extractCookies(response);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'No internet connection. Please verify your network.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(statusCode: 0, message: 'Network error: ${e.message}');
    }
  }

  Future<Uint8List> getBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final customHeaders = _buildHeaders(headers);
      customHeaders[HttpHeaders.acceptHeader] = 'application/pdf, */*';

      final response = await _client
          .get(uri, headers: customHeaders)
          .timeout(const Duration(seconds: 30));

      _extractCookies(response);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to download file (${response.statusCode})',
      );
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'No internet connection. Please verify your network.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(statusCode: 0, message: 'Network error: ${e.message}');
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final encodedBody = body is String ? body : (body != null ? jsonEncode(body) : null);

      final response = await _client
          .post(uri, headers: _buildHeaders(headers), body: encodedBody)
          .timeout(const Duration(seconds: 20));

      _extractCookies(response);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'No internet connection. Please verify your network.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(statusCode: 0, message: 'Network error: ${e.message}');
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final encodedBody = body is String ? body : (body != null ? jsonEncode(body) : null);

      final response = await _client
          .put(uri, headers: _buildHeaders(headers), body: encodedBody)
          .timeout(const Duration(seconds: 20));

      _extractCookies(response);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'No internet connection. Please verify your network.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(statusCode: 0, message: 'Network error: ${e.message}');
    }
  }

  Future<dynamic> patch(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final encodedBody = body is String ? body : (body != null ? jsonEncode(body) : null);

      final response = await _client
          .patch(uri, headers: _buildHeaders(headers), body: encodedBody)
          .timeout(const Duration(seconds: 20));

      _extractCookies(response);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'No internet connection. Please verify your network.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(statusCode: 0, message: 'Network error: ${e.message}');
    }
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await _client
          .delete(uri, headers: _buildHeaders(headers))
          .timeout(const Duration(seconds: 15));

      _extractCookies(response);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'No internet connection. Please verify your network.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(statusCode: 0, message: 'Network error: ${e.message}');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {
        return response.body;
      }
    }

    String errorMessage = 'Request failed ($statusCode)';
    dynamic errorData;

    try {
      errorData = jsonDecode(utf8.decode(response.bodyBytes));
      if (errorData is Map) {
        if (errorData.containsKey('detail')) {
          errorMessage = errorData['detail'].toString();
        } else if (errorData.containsKey('message')) {
          errorMessage = errorData['message'].toString();
        } else if (errorData.isNotEmpty) {
          final firstEntry = errorData.entries.first;
          errorMessage = '${firstEntry.key}: ${firstEntry.value}';
        }
      }
    } catch (_) {
      errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
    }

    throw ApiException(
      statusCode: statusCode,
      message: errorMessage,
      data: errorData,
    );
  }
}
