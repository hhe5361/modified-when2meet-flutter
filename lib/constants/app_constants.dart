class AppConstants {
  static const String baseUrl = "http://api.planto.sugang.click:80";
  // static const String baseUrl = "http://localhost:8080";
  static const String createRoomEndpoint = '/rooms';
  static const String loginEndpoint = '/rooms/:url/login';
  static const String getRoomInfoEndpoint = '/rooms/:url';
  static const String getUserDetailEndpoint = '/rooms/:url/user';
  static const String voteTimeEndpoint = '/rooms/:url/times';
  static const String getResultEndpoint = '/rooms/:url/result';
  static const String createNotice = '/rooms/:url/notices';
  static const String getNotice = '/rooms/:url/notices';
}
