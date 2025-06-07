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
    final userData = json['user'] as Map<String, dynamic>;
    final availableTimeList = json['available_time'] as List? ?? [];
        
    List<AvailableTime> availableTimes = availableTimeList.map((i) => AvailableTime.fromJson(i)).toList();

    final result = User(
      id: userData['id'],
      name: userData['name'],
      timeRegion: userData['time_region'],
      availableTime: availableTimes,
    );
    
    return result;
  }

  Map<String, dynamic> toJson() {
    final result = {
      'id': id,
      'name': name,
      'time_region': timeRegion,
      'available_time': availableTime.map((e) => e.toJson()).toList(),
    };
    return result;
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
    final result = AvailableTime(
      date: json['date'],
      hourStartSlot: json['hour_start_slot'],
      hourEndSlot: json['hour_end_slot'],
    );
    return result;
  }

  Map<String, dynamic> toJson() {
    final result = {
      'date': date,
      'hour_start_slot': hourStartSlot,
      'hour_end_slot': hourEndSlot,
    };
    return result;
  }
}

