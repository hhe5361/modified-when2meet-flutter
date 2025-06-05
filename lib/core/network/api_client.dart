import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:my_web/constants/app_constants.dart';
import 'package:my_web/core/network/api_exceptions.dart';

class ApiClient {
  final _logger = Logger('ApiClient');
  final http.Client _client = http.Client();
  final baseUrl = AppConstants.baseUrl;

  ApiClient() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Future<dynamic> post(String path, dynamic body, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    _logger.info('Making POST request to: $uri');
    _logger.fine('Request body: ${json.encode(body)}');
    
    try {
      final res = await _client.post(
        uri,
        headers: _getHeaders(token),
        body: json.encode(body)
      );

      _logger.info('Response status code: ${res.statusCode}');
      _logger.fine('Response body: ${res.body}');

      return _processResponse(res);
    } catch (e) {
      _logger.severe('Error during POST request: $e');
      throw FetchDataException('Error during communication: $e');
    }
  }

  Future<dynamic> get(String path, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    _logger.info('Making GET request to: $uri');

    try {
      final response = await _client.get(
        uri,
        headers: _getHeaders(token),
      );

      _logger.info('Response status code: ${response.statusCode}');
      _logger.fine('Response body: ${response.body}');

      return _processResponse(response);
    } catch (e) {
      _logger.severe('Error during GET request: $e');
      throw FetchDataException('Error occurred: $e');
    }
  }

  Future<dynamic> put(String path, dynamic body, {String? token}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    _logger.info('Making PUT request to: $uri');
    _logger.fine('Request body: ${json.encode(body)}');

    try {
      final response = await _client.put(
        uri,
        headers: _getHeaders(token),
        body: json.encode(body),
      );

      _logger.info('Response status code: ${response.statusCode}');
      _logger.fine('Response body: ${response.body}');

      return _processResponse(response);
    } catch (e) {
      _logger.severe('Error during PUT request: $e');
      throw FetchDataException('Error occurred: $e');
    }
  }

  Map<String, String> _getHeaders(String? token) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    _logger.fine('Request headers: $headers');
    return headers;
  }

  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return json.decode(response.body);
      case 400:
        _logger.warning('Bad request error: ${response.body}');
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        _logger.warning('Unauthorized error: ${response.body}');
        throw UnauthorizedException(response.body.toString());
      case 404:
        _logger.warning('Not found error: ${response.body}');
        throw NotFoundException(response.body.toString());
      case 500:
        _logger.severe('Server error: ${response.body}');
        throw InternalServerErrorException(response.body.toString());
      default:
        _logger.severe('Unexpected error: ${response.statusCode} - ${response.body}');
        throw FetchDataException(
            'Error occurred with Status Code : ${response.statusCode}');
    }
  }
}
