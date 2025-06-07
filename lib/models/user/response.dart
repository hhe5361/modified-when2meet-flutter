import 'package:my_web/models/user/model.dart';

class RegisterLoginResponse {
  final String message;
  final User user;
  final String jwtToken;

  RegisterLoginResponse({
    required this.message,
    required this.user,
    required this.jwtToken,
  });

  factory RegisterLoginResponse.fromJson(Map<String, dynamic> json) {
    return RegisterLoginResponse(
      message: json['message'],
      user: User.fromJson(json['data']['user']),
      jwtToken: json['data']['jwt_token'],
    );
  }
}

class TimeSlot {
  final int hour;
  bool selected;

  TimeSlot({required this.hour, required this.selected});
}
