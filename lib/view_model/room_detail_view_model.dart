import 'package:flutter/material.dart';
import 'package:my_web/constants/enum/time_region.dart';
import 'package:my_web/core/network/api_client.dart';
import 'package:my_web/models/room/model.dart';
import 'package:my_web/models/room/response.dart';
import 'package:my_web/models/user/model.dart';
import 'package:my_web/models/user/request.dart';
import 'package:my_web/models/user/response.dart';
import 'package:my_web/repository/room_repository.dart';
import 'package:my_web/view_model/session_service.dart';

//user 분리 시켜도 될 듯 리팩토링할 때
class RoomDetailViewModel extends ChangeNotifier {
  final RoomRepository _roomRepository = RoomRepository(ApiClient());
  final SessionService _session;

  RoomDetailViewModel(this._session);

  bool _isLoading = false;
  String? _errMsg;
  String? _sucsMsg;

  Room? _roomInfo;
  Map<String, List<HourBlock>>? _voteTable;
  Map<String, List<TimeSlot>>? _selectedTimeSlots;
  // User? _currentUser;
  // String? _jwtToken;
  // bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errMsg;
  String? get successMessage => _sucsMsg;
  Room? get roomInfo => _roomInfo;
  Map<String, List<HourBlock>>? get voteTable => _voteTable;
  // User? get currentUser => _session.currentUser;
  // bool get isLoggedIn => _session.isLoggedIn;
  Map<String, List<TimeSlot>>? get selectedTimeSlots => _selectedTimeSlots;

  Future<void> init(String roomUrl) async {
    await fetchRoomDetails(roomUrl);
  }

  void setStart() {
    _isLoading = true;
    _errMsg = null;
    _sucsMsg = null;
    notifyListeners(); //Loading need
  }

  void setEnd() {
    _isLoading = false;
    notifyListeners();
  }

  void setSelectedTimeSlot({String? targetName}) {
    _selectedTimeSlots = {};
    _voteTable!.forEach((date, hours) {
      List<TimeSlot> slots = [];
      for (var val in hours) {
        bool isSelected = false;
        if (targetName != null) {
          isSelected = val.user.any((user) => user == targetName);
        }
        TimeSlot slot = TimeSlot(hour: val.hour, selected: isSelected);
        slots.add(slot);
      }
      _selectedTimeSlots![date] = slots;
    });
  }

  void updateSelectedTimeSlot() {}

  Future<void> fetchRoomDetails(String roomUrl) async {
    setStart();

    try {
      final res = await _roomRepository.getRoomInfo(roomUrl);

      _roomInfo = res.roomInfo;
      _voteTable = res.voteTable;
      if (!_session.isLoggedIn) {
        setSelectedTimeSlot();
      }

      _sucsMsg = "Room details fetched successfully.";
    } catch (e) {
      _errMsg = e.toString();
    } finally {
      setEnd();
    }
  }

  Future<void> voteTime(String roomUrl) async {
    if (!_session.isLoggedIn || _session.jwtToken == null) {
      _errMsg = "Please log in to vote.";
      notifyListeners();
      return;
    }
    setStart();

    try {
      final VoteTimeRequest req = VoteTimeRequest.fromTimeSlot(
        _selectedTimeSlots!,
      );
      await _roomRepository.voteTime(roomUrl, _session.jwtToken!, req);

      _sucsMsg = "Vote updated successfully!";

      await fetchRoomDetails(roomUrl);
    } catch (e) {
      _errMsg = e.toString();
    } finally {
      setEnd();
    }
  }

  List<String> getVotersForSlot(String date, int hour) {
    final block = _voteTable![date]!.firstWhere((block) => block.hour == hour);
    return block.user;
  }

  void toggleTimeSlot(String date, int idx) {
    if (!_session.isLoggedIn) {
      _errMsg = "Please log in to vote.";
      notifyListeners();
      return;
    }
    if (_selectedTimeSlots![date]![idx].selected) {
      _selectedTimeSlots![date]![idx].selected = false;
    } else {
      _selectedTimeSlots![date]![idx].selected = true;
    }
    notifyListeners();
  }

  void clearMessages() {
    _errMsg = null;
    _sucsMsg = null;
    notifyListeners();
  }

  // Future<void> login(String roomUrl, String name, String pwd, TimeRegion timeRegion) async{
  //   setStart();

  //   try {
  //     final req = RegisterLoginRequest(name: name, password: pwd, timeRegion: timeRegion);
  //     final res = await _roomRepository.registerOrLogin(req, roomUrl);
  //     _session.currentUser = res.user;
  //     _session.jwtToken = res.jwtToken;
  //     _sucsMsg = res.message;

  //     for (var time in _session.currentUser!.availableTime){
  //       for (int i = time.hourStartSlot; i < time.hourEndSlot; i++){
  //         _selectedTimeSlots![time.date]![i].selected = true;
  //       }
  //     }
  //   } catch(e) {
  //     _errMsg = e.toString();
  //     _session.currentUser = null;
  //     _session.jwtToken = null;

  //   } finally {
  //     setEnd();
  //   }
  // }

  // void logout() {
  //   _session.currentUser = null;
  //   _session.jwtToken = null;
  //   _selectedTimeSlots = {};
  //   notifyListeners();
  // }
}
