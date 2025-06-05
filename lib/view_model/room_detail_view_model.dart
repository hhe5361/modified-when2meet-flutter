import 'package:flutter/material.dart';
import 'package:my_web/core/network/api_client.dart';
import 'package:my_web/models/room/model.dart';
import 'package:my_web/models/user/model.dart';
import 'package:my_web/models/user/request.dart';
import 'package:my_web/repository/room_repository.dart';

//user 분리 시켜도 될 듯 리팩토링할 때 
class RoomDetailViewModel extends ChangeNotifier{
  final RoomRepository _roomRepository = RoomRepository(ApiClient());

  bool _isLoading = false;
  String? _errMsg;
  String? _sucsMsg;

  Room? _roomInfo;
  List<VoteableDate> _votableDates = [];
  List<Map<String,dynamic>> _allUsersData = [];

  User? _currentUser;
  String? _jwtToken;
  bool _isLoggedIn = false;

  Set<String> _selectedTimeSlots = {}; //year-month-hh 이런 식으로 저장 ? 

  bool get isLoading => _isLoading;
  String? get errorMessage => _errMsg;
  String? get successMessage => _sucsMsg;
  Room? get roomInfo => _roomInfo;
  List<VoteableDate> get votableDates => _votableDates;
  List<Map<String, dynamic>> get allUsersData => _allUsersData;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  Set<String> get selectedTimeSlots => _selectedTimeSlots;

  Future<void> init(String roomUrl) async {
    await fetchRoomDetails(roomUrl);
  }

  void setStart(){
    _isLoading = true;
    _errMsg = null;
    _sucsMsg = null;
    notifyListeners();
  }

  Future<void> fetchRoomDetails(String roomUrl) async{
    setStart();

    try{
      final res = await _roomRepository.getRoomInfo(roomUrl);
      
      if (res['roomInfo']?['room'] != null) {
        _roomInfo = Room.fromJson(res['roomInfo']['room']);
      } else {
        _errMsg = "Failed to load room information";
        return;
      }

      if (res['roomInfo']?['dates'] != null) {
        _votableDates = (res['roomInfo']['dates'] as List)
          .map((e) => VoteableDate.fromJson(e))
          .toList();
      } else {
        _votableDates = []; // Initialize as empty list if dates are null
      }

      if (res['users'] != null) {
        _allUsersData = (res['users'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      } else {
        _allUsersData = []; // Initialize as empty list if users are null
      }
      
      _sucsMsg = "Room details fetched successfully.";
    } catch (e) { 
      _errMsg = e.toString();
    } finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String roomUrl, String name, String pwd, String timeRegion) async{
    setStart();

    try {
      final req = RegisterLoginRequest(name: name, password: pwd, timeRegion: timeRegion);
      final res = await _roomRepository.registerOrLogin(req, roomUrl);
      _currentUser = res.user;
      _jwtToken = res.jwtToken;
      _isLoggedIn = true;
      _sucsMsg = res.message;

      //update current user available times in the alluserdata list
      final userIndex = _allUsersData.indexWhere((userData) => userData['user']['id'] == _currentUser!.id);
      
      if(userIndex != -1) {
        _allUsersData[userIndex] = {
          'user' : _currentUser!.toJson(),
          'available_time' : _currentUser!.availableTime.map((e) => e.toJson()).toList(),
        };
      }else{
        _allUsersData.add({
          'user' : _currentUser!.toJson(),
          'available_time': _currentUser!.availableTime.map((e) => e.toJson()).toList(),
        });

      }

      //innit selected Time Slots from current User's available time
      _selectedTimeSlots.clear();
      for (var time in _currentUser!.availableTime){
        for (int i = time.hourStartSlot; i < time.hourEndSlot; i++){
          _selectedTimeSlots.add('${time.date}_$i');
        }
      }
    } catch(e) {
      _errMsg = e.toString();
      _isLoggedIn = false;

    } finally {
      _isLoading = false;
      notifyListeners();

    }
  }

  Future<void> voteTime(String roomUrl) async {
    if (!_isLoggedIn || _jwtToken == null) {
      _errMsg = "Please log in to vote.";
      notifyListeners();
      return;
    }

    setStart();

    try {
      // Group selected slots by date
      Map<String, List<int>> slotsByDate = {};
      for (var slot in _selectedTimeSlots) {
        final parts = slot.split('_');
        final date = parts[0];
        final hour = int.parse(parts[1]);
        slotsByDate.putIfAbsent(date, () => []).add(hour);
      }

      // Convert to AvailableTime objects and send to API
      for (var entry in slotsByDate.entries) {
        final date = entry.key;
        final hours = entry.value..sort(); // Sort hours to find continuous blocks

        if (hours.isEmpty) continue;

        int currentStart = hours.first;
        int currentEnd = hours.first + 1;

        for (int i = 1; i < hours.length; i++) {
          if (hours[i] == currentEnd) {
            currentEnd++;
          } else {
            // Found a break, send the previous block
            await _roomRepository.voteTime(
              roomUrl,
              _jwtToken!,
              AvailableTime(date: date, hourStartSlot: currentStart, hourEndSlot: currentEnd),
            );
            currentStart = hours[i];
            currentEnd = hours[i] + 1;
          }
        }
        // Send the last block
        await _roomRepository.voteTime(
          roomUrl,
          _jwtToken!,
          AvailableTime(date: date, hourStartSlot: currentStart, hourEndSlot: currentEnd),
        );
      }

      _sucsMsg = "Vote updated successfully!";
      // Re-fetch room details to update all users' votes
      await fetchRoomDetails(roomUrl);
    } catch (e) {
      _errMsg = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleTimeSlot(DateTime date, int hour) {
    if (!_isLoggedIn) {
      _errMsg = "Please log in to vote.";
      notifyListeners();
      return;
    }
    final String key = '${date.toIso8601String().split('T')[0]}_$hour';
    if (_selectedTimeSlots.contains(key)) {
      _selectedTimeSlots.remove(key);
    } else {
      _selectedTimeSlots.add(key);
    }
    notifyListeners();
  }

    List<String> getVotersForSlot(DateTime date, int hour) {
    final String targetDate = date.toIso8601String().split('T')[0];
    List<String> voters = [];

    for (var userData in _allUsersData) {
      final user = User.fromJson(userData['user']);
      final availableTimes = (userData['available_time'] as List)
          .map((e) => AvailableTime.fromJson(e))
          .toList();

      for (var time in availableTimes) {
        if (time.date == targetDate &&
            hour >= time.hourStartSlot &&
            hour < time.hourEndSlot) {
          voters.add(user.name);
          break; // User has voted for this slot, no need to check other blocks for this user
        }
      }
    }
    return voters;
  }

  void clearMessages() {
    _errMsg = null;
    _sucsMsg = null;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _jwtToken = null;
    _isLoggedIn = false;
    _selectedTimeSlots.clear();
    notifyListeners();
  }

}