import 'package:my_web/models/notice/model.dart';

class NoticeResponse {
  final List<Notice> contents;

  NoticeResponse({
    required this.contents,
  });

factory NoticeResponse.fromJson(List<dynamic> jsonList) {
  return NoticeResponse(
    contents: jsonList
        .cast<Map<String, dynamic>>() 
        .map((json) => Notice.fromJson(json))
        .toList(),
  );
}
}
