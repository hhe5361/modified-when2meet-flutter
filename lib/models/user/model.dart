class User {
  final int id;
  final String name;
  final String timeRegion;
  final List<AvailableTime> availableTime;

  User({
    required this.id,
    required this.name,
    required this.timeRegion,
    required this.availableTime,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var availableTimeList = json['available_time'] as List;
    List<AvailableTime> availableTimes = availableTimeList.map((i) => AvailableTime.fromJson(i)).toList();

    return User(
      id: json['id'],
      name: json['name'],
      timeRegion: json['time_region'],
      availableTime: availableTimes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'time_region': timeRegion,
      'available_time': availableTime.map((e) => e.toJson()).toList(),
    };
  }
}

class AvailableTime {
  final String date;
  final int hourStartSlot;
  final int hourEndSlot;

  AvailableTime({
    required this.date,
    required this.hourStartSlot,
    required this.hourEndSlot,
  });

  factory AvailableTime.fromJson(Map<String, dynamic> json) {
    return AvailableTime(
      date: json['date'],
      hourStartSlot: json['hour_start_slot'],
      hourEndSlot: json['hour_end_slot'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'hour_start_slot': hourStartSlot,
      'hour_end_slot': hourEndSlot,
    };
  }
}
