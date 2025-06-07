import 'package:flutter/material.dart';
import 'package:my_web/core/network/api_client.dart';
import 'package:my_web/models/notice/model.dart';
import 'package:my_web/models/notice/request.dart';
import 'package:my_web/repository/room_repository.dart';
import 'package:my_web/view_model/session_service.dart';

class NoticeViewModel extends ChangeNotifier {
  final RoomRepository _roomRepository = RoomRepository(ApiClient());
  final SessionService _session;

  List<Notice> notices = [];
  bool isLoading = false;

  NoticeViewModel(this._session);

  Future<void> init(String roomUrl) async {
    await fetchNotices(roomUrl);
  }

  Future<void> fetchNotices(String roomUrl) async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await _roomRepository.getNotices(roomUrl);
      notices = res.contents;
      notices.sort((a, b) => b.createdAt.compareTo(a.createdAt)); 

    } catch (e) {
      print('Error fetching notices: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> createNotice(String content, String url) async {
    final req = CreateNoticeRequest(content: content);
    if(!_session.isLoggedIn) return;
    try {
      await _roomRepository.createNotice(req, url, _session.jwtToken!);
      await fetchNotices(url); // 공지 생성 후 다시 불러오기
    } catch (e) {
      print('Error creating notice: $e');
    }
  }
}
