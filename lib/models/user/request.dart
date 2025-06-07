import 'package:my_web/constants/enum/time_region.dart';
import 'package:my_web/models/user/model.dart';
import 'package:my_web/models/user/response.dart';

class RegisterLoginRequest {
  final String name;
  final String password;
  final TimeRegion timeRegion;

  RegisterLoginRequest({
    required this.name,
    required this.password,
    required this.timeRegion,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'password': password,
      'time_region': timeRegion.value,
    };
  }
}

class VoteTimeRequest{
  final List<AvailableTime> times ;

  VoteTimeRequest({required this.times});
  
  Map<String,dynamic> toJson(){
    return{
      'times' : times
    };
  }

  factory VoteTimeRequest.fromTimeSlot(Map<String, List<TimeSlot>> slots ){ //특정 date 
    final List<AvailableTime> result = [];

    for(var entry in slots.entries){
      var date = entry.key;
      int start = -1;
      int end = -1;

      for (var slot in entry.value){
        if(slot.selected == true) {
          if(start == -1) {
            start = slot.hour;
          }
          end = slot.hour;
        }
        else {
          if(start != -1) {
            AvailableTime out = AvailableTime(date: date,
                hourStartSlot: start, hourEndSlot: end);
            result.add(out);
            start = -1;
          }
        }
      }

      if (start != -1) {
        result.add(AvailableTime(date: date,
            hourStartSlot: start, hourEndSlot: end));
      }
    }
    return VoteTimeRequest(times: result);
  }
}