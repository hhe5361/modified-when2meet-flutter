import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_web/constants/app_constants.dart';
import 'package:my_web/core/network/api_exceptions.dart';

class ApiClient {
  final http.Client _client = http.Client();
  final baseUrl = AppConstants.baseUrl;
  //post request to server 
  Future<dynamic> post(String path, dynamic body, {String ? token}) async{
    final uri = Uri.parse('$baseUrl$path');
    try {
      final res = await _client.post(
        uri,
        headers: _getHeaders(token),
        body: json.encode(body)
      );

      return _processResponse(res);

    } catch (e){
      throw FetchDataException('error : $e');
    }
  }

  Future<dynamic> get(String path , {String ? token}) async{
    final uri = Uri.parse('$baseUrl$path');

    try {
      final response = await _client.get(
        uri,
        headers: _getHeaders(token),
      );

      return _processResponse(response);

    }catch (e) {
      throw FetchDataException('Error occurred: $e');
    }
  }

  Future<dynamic> put(String path, dynamic body, {String? token}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    try {
      final response = await _client.put(
        uri,
        headers: _getHeaders(token),
        body: json.encode(body),
      );
      return _processResponse(response);
    } catch (e) {
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
    return headers;
  }

  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return json.decode(response.body);
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorizedException(response.body.toString());
      case 404:
        throw NotFoundException(response.body.toString());
      case 500:
        throw InternalServerErrorException(response.body.toString());
      default:
        throw FetchDataException(
            'Error occurred with Status Code : ${response.statusCode}');
    }
  }
}
