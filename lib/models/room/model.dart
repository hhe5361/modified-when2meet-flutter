class Room {
  final int id;
  final String name;
  final String url;
  final String timeRegion;
  final int startTime;
  final int endTime;
  final bool isOnline;

  Room({
    required this.id,
    required this.name,
    required this.url,
    required this.timeRegion,
    required this.startTime,
    required this.endTime,
    required this.isOnline,
  });

  //jfosn -> room 
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      timeRegion: json['time_region'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isOnline: json['is_online'],
    );
  }

    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'time_region': timeRegion,
      'start_time': startTime,
      'end_time': endTime,
      'is_online': isOnline,
    };
  }
}

class VoteableDate {
  final int year;
  final int month;
  final int day;

  VoteableDate({
    required this.year,
    required this.month,
    required this.day,
  });

  factory VoteableDate.fromJson(Map<String, dynamic> json) {
    return VoteableDate(
      year: json['year'],
      month: json['month'],
      day: json['day'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'day': day,
    };
  }
}
