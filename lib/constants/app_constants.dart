class AppConstants {
  static const String baseUrl = "localhost:8000";
  static const String createRoomEndpoint = '/rooms';
  static const String loginEndpoint = '/rooms/:url/login';
  static const String getRoomInfoEndpoint = '/rooms/:url';
  static const String getUserDetailEndpoint = '/rooms/:url/user';
  static const String voteTimeEndpoint = '/rooms/:url/times';
  static const String getResultEndpoint = '/rooms/:url/result';
}
