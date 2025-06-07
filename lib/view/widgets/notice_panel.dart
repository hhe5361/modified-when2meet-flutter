// import 'package:flutter/material.dart';
// import 'package:my_web/view_model/notice_view_model.dart';
// import 'package:provider/provider.dart';

// class NoticePanel extends StatefulWidget {
//   const NoticePanel({super.key});

//   @override
//   State<NoticePanel> createState() => _NoticePanelState();
// }

// class _NoticePanelState extends State<NoticePanel> {
//   final TextEditingController _controller = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final vm = context.watch<NoticeViewModel>();
//     final currentUserName = "Liam"; //Login View Model 따로 빼는게 깔끔할 것 같은데 시간 부족.. 

//     return Column(
//       children: [
//         const SizedBox(height: 16),
//         const Text("Chat", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

//         const SizedBox(height: 8),
//         Expanded(
//           child: vm.isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : ListView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   reverse: false,
//                   itemCount: vm.notices.length,
//                   itemBuilder: (context, index) {
//                     final notice = vm.notices[index];
//                     final isMe = notice.userName == currentUserName;

//                     return Align(
//                       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(vertical: 4),
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Column(
//                           crossAxisAlignment:
//                               isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               notice.userName,
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: isMe ? Colors.blue : Colors.black54,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(notice.content),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//         ),

//         Padding(
//           padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
//           child: Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _controller,
//                   decoration: InputDecoration(
//                     hintText: "Type a message",
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               IconButton(
//                 icon: const Icon(Icons.send, color: Colors.blue),
//                 onPressed: () {
//                   final content = _controller.text.trim();
//                   if (content.isNotEmpty) {
//                     vm.createNotice(content);
//                     _controller.clear();
//                   }
//                 },
//               )
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
