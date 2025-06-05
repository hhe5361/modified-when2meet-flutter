import 'package:my_web/models/room/model.dart';

class CreateRoomRequest {
  final String roomName;
  final String timeRegion; //this is ENUM !!!!!!
  final int startTime;
  final int endTime;
  final bool isOnline;
  final List<VoteableDate> voteableDates;

  CreateRoomRequest({
    required this.roomName,
    required this.timeRegion,
    required this.startTime,
    required this.endTime,
    required this.isOnline,
    required this.voteableDates,
  });

  Map<String, dynamic> toJson() => {
    'room_name': roomName,
    'time_region': timeRegion,
    'start_time': startTime,
    'end_time': endTime,
    'is_online': isOnline,
    'voteable_rooms': voteableDates.map((date) => date.toJson()).toList(),
  };
}

