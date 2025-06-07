import 'package:flutter/material.dart';
import 'package:my_web/constants/enum/time_region.dart';
import 'package:my_web/core/network/api_client.dart';
import 'package:my_web/models/user/model.dart';
import 'package:my_web/models/user/request.dart';
import 'package:my_web/repository/room_repository.dart';

class SessionService extends ChangeNotifier {
  final RoomRepository _roomRepository = RoomRepository(ApiClient());

  String? jwtToken;
  User? currentUser;

  bool get isLoggedIn => jwtToken != null && currentUser != null;

  void clear() {
    jwtToken = null;
    currentUser = null;
    notifyListeners();
  }

  Future<void> login({
    required String roomUrl,
    required String name,
    required String password,
    required TimeRegion timeRegion,
  }) async {
    final req = RegisterLoginRequest(
        name: name, password: password, timeRegion: timeRegion);
    final res = await _roomRepository.registerOrLogin(req, roomUrl);

    jwtToken = res.jwtToken;
    currentUser = res.user;
    notifyListeners();
  }

  void logout() {
    clear();
  }
}
