import 'package:my_web/models/room/model.dart';

class CreateRoomResponse {
  final String message;
  final String url;

  CreateRoomResponse({
    required this.message,
    required this.url,
  });

  factory CreateRoomResponse.fromJson(Map<String, dynamic> json) {
    return CreateRoomResponse(
      message: json['message'],
      url: json['data']['url'],
    );
  }
}

class HourBlock{
  final int hour;
  final List<String> user;

  HourBlock({
    required this.hour,
    required this.user
  });

  factory HourBlock.fromJson(Map<String, dynamic> json){
    return HourBlock(hour: json['hour'], user: List<String>.from(json['user_name']));
  }
}

class RoomInfoResponse{
  final Room roomInfo;
  final Map<String, List<HourBlock>> voteTable;

  RoomInfoResponse({
    required this.roomInfo,
    required this.voteTable
  });

  factory RoomInfoResponse.fromJson(Map<String,dynamic> json){
    final voteTableJson = json['vote_table'] as Map<String, dynamic>;
    final voteTableParsed = voteTableJson.map((date, blocks) {
      final blockList = (blocks as List)
          .map((e) => HourBlock.fromJson(e as Map<String, dynamic>))
          .toList();
      return MapEntry(date, blockList);
    });

    return RoomInfoResponse(roomInfo: Room.fromJson(json['roomInfo']), voteTable: voteTableParsed)
    ;   
  }
}