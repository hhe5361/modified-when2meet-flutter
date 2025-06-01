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