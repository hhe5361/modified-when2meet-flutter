import 'package:my_web/models/room/model.dart';

class CreateNoticeRequest {
  final String content;

  CreateNoticeRequest({
    required this.content,
  });

  Map<String, dynamic> toJson() => {
    'content': content,
  };
}

