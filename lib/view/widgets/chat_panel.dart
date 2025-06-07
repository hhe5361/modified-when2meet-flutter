// import 'package:flutter/material.dart';

// class ChatPanel extends StatelessWidget {
//   const ChatPanel({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         border: Border(left: BorderSide(color: Colors.grey.shade300)),
//       ),
//       child: Column(
//         children: [
//           const Text(
//             'Chat',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: ListView(
//               children: const [
//                 ChatMessage(
//                   sender: 'Olivia',
//                   message: 'Hey everyone, just voted for my preferred times. Looking forward to our kickoff!',
//                   isMe: false,
//                 ),
//                 ChatMessage(
//                   sender: 'Liam',
//                   message: 'Thanks, Olivia! I\'ll cast my vote now.',
//                   isMe: true,
//                 ),
//                 // Add more chat messages here
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildMessageInput(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageInput() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Type a message',
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               ),
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.send, color: Colors.blue),
//             onPressed: () {
//               // Handle sending message (UI only)
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ChatMessage extends StatelessWidget {
//   final String sender;
//   final String message;
//   final bool isMe;

//   const ChatMessage({
//     super.key,
//     required this.sender,
//     required this.message,
//     required this.isMe,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//         padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
//         decoration: BoxDecoration(
//           color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
//           borderRadius: BorderRadius.only(
//             topLeft: const Radius.circular(12),
//             topRight: const Radius.circular(12),
//             bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
//             bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//           children: [
//             Text(
//               sender,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//                 color: isMe ? Colors.blue.shade800 : Colors.grey.shade700,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               message,
//               style: const TextStyle(fontSize: 14),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
