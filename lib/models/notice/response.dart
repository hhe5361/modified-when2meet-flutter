import 'package:my_web/models/notice/model.dart';

class NoticeResponse {
  final List<Notice> contents;

  NoticeResponse({
    required this.contents,
  });

  factory NoticeResponse.fromJson(List<Map<String, dynamic>> jsonList) {
    return NoticeResponse(
      contents: jsonList.map((json) => Notice.fromJson(json)).toList(),
    );
  }
}
