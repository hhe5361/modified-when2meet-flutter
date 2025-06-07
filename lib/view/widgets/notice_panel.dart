import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_web/models/user/model.dart';
import 'package:my_web/view_model/notice_view_model.dart';
import 'package:my_web/view_model/session_service.dart';
import 'package:provider/provider.dart';

class NoticePanel extends StatefulWidget {
  final String roomUrl;

  const NoticePanel({super.key, required this.roomUrl});

  @override
  State<NoticePanel> createState() => _NoticePanelState();
}

class _NoticePanelState extends State<NoticePanel> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NoticeViewModel>();
    final User? user = context.watch<SessionService>().currentUser;
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          "Notice",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Divider(
          color: Colors.grey.withAlpha(100), thickness: 1
        ),
        const SizedBox(height: 8),
        Expanded(
          child:
              vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: vm.notices.length,
                    itemBuilder: (context, index) {
                      final notice = vm.notices[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(
                            notice.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(notice.content),
                          trailing: Text(
                            DateFormat(
                              'yyyy-MM-dd HH:mm',
                            ).format(notice.createdAt),
                          ),
                        ),
                      );
                    },
                  ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: () {
                  final content = _controller.text.trim();
                  final isLoggedIn = context.read<SessionService>().isLoggedIn;

                  if (!isLoggedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login first.')),
                    );
                    return;
                  }

                  if (content.isNotEmpty) {
                    vm.createNotice(content, widget.roomUrl);
                    _controller.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
