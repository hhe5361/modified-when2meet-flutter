import 'package:flutter/material.dart';
import 'package:my_web/core/network/api_client.dart';
import 'package:my_web/models/room/model.dart';
import 'package:my_web/models/room/request.dart';
import 'package:my_web/repository/room_repository.dart';
import 'package:flutter/foundation.dart';

//view 에 그릴 데이터 여기서 의존성 가짐. 
class HomeViewModel extends ChangeNotifier{ 
  final RoomRepository _roomRepository = RoomRepository(ApiClient());

  bool _isLoading = false;
  String? _errMsg;
  String? _sucsMsg;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errMsg;
  String? get successMessage => _sucsMsg;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> createRoom({
    required String roomName,
    required String timeRegion,
    required int startTime,
    required int endTime,
    required bool isOnline,
    required List<VoteableDate> voteableDates,
    required Function(String roomUrl) onSuccess,
  }) async {
    _isLoading = true;
    _errMsg = null;
    _sucsMsg = null;
    notifyListeners();

    try {
      final request = CreateRoomRequest(
        roomName: roomName,
        timeRegion: timeRegion,
        startTime: startTime,
        endTime: endTime,
        isOnline: isOnline,
        voteableDates: voteableDates,
      );
      final response = await _roomRepository.createRoom(request);
      _sucsMsg = response.message;
      onSuccess(response.url);
    } catch (e) {
      _errMsg = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); //reload widget 
    }
  }

  void clearMessages() {
    _errMsg = null;
    _sucsMsg = null;
    notifyListeners(); //reload widget 
  }

}