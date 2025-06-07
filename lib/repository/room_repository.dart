import 'package:my_web/constants/app_constants.dart';
import 'package:my_web/core/network/api_client.dart';
import 'package:my_web/models/notice/request.dart';
import 'package:my_web/models/notice/response.dart';
import 'package:my_web/models/room/request.dart';
import 'package:my_web/models/room/response.dart';
import 'package:my_web/models/user/model.dart';
import 'package:my_web/models/user/request.dart';
import 'package:my_web/models/user/response.dart';


class RoomRepository {
  final ApiClient _apiClient;

  RoomRepository(this._apiClient);

  String _getUrl(String endpoint, String url) => endpoint.replaceFirst(':url', url);

  Future<T> _post<T>(String endpoint, dynamic body, T Function(Map<String, dynamic>) fromJson, {String? url, String? token}) async {
    final path = url != null ? _getUrl(endpoint, url) : endpoint;
    final res = await _apiClient.post(path, body, token: token);
    return fromJson(res);
  }

  Future<T> _get<T>(String endpoint, T Function(Map<String, dynamic>) fromJson, {String? url, String? token}) async {
    final path = url != null ? _getUrl(endpoint, url) : endpoint;
    final res = await _apiClient.get(path, token: token);
    return fromJson(res);
  }

  Future<CreateRoomResponse> createRoom(CreateRoomRequest req) => 
    _post(AppConstants.createRoomEndpoint, req.toJson(), CreateRoomResponse.fromJson);

  Future<RegisterLoginResponse> registerOrLogin(RegisterLoginRequest req, String url) =>
    _post(AppConstants.loginEndpoint, req.toJson(), RegisterLoginResponse.fromJson, url: url);

  Future<RoomInfoResponse> getRoomInfo(String url) =>
    _get(AppConstants.getRoomInfoEndpoint, (res) => RoomInfoResponse.fromJson(res['data']), url: url);

  Future<User> getUserDetail(String url, String token) =>
    _get(AppConstants.getUserDetailEndpoint, (res) => User.fromJson(res['data']['user']), url: url, token: token);

  Future<void> voteTime(String url, String token, VoteTimeRequest time) async {
    await _apiClient.put(
      _getUrl(AppConstants.voteTimeEndpoint, url),
      time.toJson(),
      token: token
    );
  }

  Future<Map<String, dynamic>> getResult(String url) =>
    _get(AppConstants.getResultEndpoint, (res) => res['data'], url: url);

  Future<String> createNotice(CreateNoticeRequest req, String url, String token) =>
    _post(AppConstants.createNotice, req.toJson() , (res) => res['message'],  url: url, token: token);
  
  Future<NoticeResponse> getNotices(String url) =>
    _get(AppConstants.getNotice, (res) => NoticeResponse.fromJson(res['data']), url: url);
}
