import 'package:flutter/material.dart';
import 'package:my_web/core/util/app.dart';
import 'package:my_web/view/widgets/chat_panel.dart';
import 'package:my_web/view/widgets/custom_button.dart';
import 'package:my_web/view/widgets/login_dialog.dart';
import 'package:my_web/view/widgets/time_grid_widget.dart';
import 'package:my_web/view_model/room_detail_view_model.dart';
import 'package:provider/provider.dart';

class RoomDetailScreen extends StatefulWidget{
  final String roomUrl;

  const RoomDetailScreen({super.key, required this.roomUrl});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen>{
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoomDetailViewModel>(context,listen: false).init(widget.roomUrl);
    });
  }

  void _showLoginDialog(BuildContext ctx){
    showDialog(context: ctx, 
    builder: (BuildContext dialogCtx){
        return LoginDialog(
          onLogin: (name, password) {
            final roomDetailViewModel = Provider.of<RoomDetailViewModel>(context, listen: false);
            roomDetailViewModel.login(widget.roomUrl, name, password, 'Asia/Seoul'); //time region 부분 고쳐야함. 
            Navigator.of(dialogCtx).pop();
          },
        );
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<RoomDetailViewModel>(
          builder: (context, viewModel, child) {
            return Text(viewModel.roomInfo?.name ?? 'Loading Room...');
          },
        ),
        centerTitle: false,
        actions: [
          Consumer<RoomDetailViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoggedIn) {
                return Row(
                  children: [
                    Text('Welcome, ${viewModel.currentUser?.name ?? ''}'),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        viewModel.logout();
                        AppUtils.showSnackBar(context, 'Logged out successfully!');
                      },
                      child: const Text('Logout', style: TextStyle(color: Colors.black)),
                    ),
                  ],
                );
              } else {
                return TextButton(
                  onPressed: () => _showLoginDialog(context),
                  child: const Text('Login', style: TextStyle(color: Colors.black)),
                );
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<RoomDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.roomInfo == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppUtils.showSnackBar(context, viewModel.errorMessage!, err: true);
              viewModel.clearMessages();
            });
          }
          if (viewModel.successMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppUtils.showSnackBar(context, viewModel.successMessage!);
              viewModel.clearMessages();
            });
          }

          if (viewModel.roomInfo == null) {
            return const Center(child: Text('Failed to load room details.'));
          }

          final screenWidth = MediaQuery.of(context).size.width;
          final bool showChatPanel = screenWidth > 900; // Adjust breakpoint as needed

          return Row(
            children: [
              Expanded(
                flex: showChatPanel ? 3 : 1, // Main content takes more space if chat is visible
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Container(
                      width: AppUtils.getResponsiveWidth(context, desktopWidth: 1200, tabletWidth: 700),
                      constraints: BoxConstraints(maxWidth: showChatPanel ? 900 : double.infinity), // Limit width for main content
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            viewModel.roomInfo!.name,
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vote on the best time for "${viewModel.roomInfo!.name}"',
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 32),
                          TimeGridWidget(
                            roomInfo: viewModel.roomInfo!,
                            votableDates: viewModel.votableDates,
                            allUsersData: viewModel.allUsersData,
                            selectedTimeSlots: viewModel.selectedTimeSlots,
                            onTimeSlotToggled: viewModel.toggleTimeSlot,
                            getVotersForSlot: viewModel.getVotersForSlot,
                            isLoggedIn: viewModel.isLoggedIn,
                          ),
                          const SizedBox(height: 32),
                          Align(
                            alignment: Alignment.centerRight,
                            child: CustomButton(
                              text: 'Vote',
                              onPressed: viewModel.isLoggedIn
                                  ? () => viewModel.voteTime(widget.roomUrl)
                                  : () {}, // Return empty function instead of null
                              isLoading: viewModel.isLoading,
                              width: 150,
                              height: 50,
                              color: viewModel.isLoggedIn ? Theme.of(context).primaryColor : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (showChatPanel)
                Expanded(
                  flex: 1,
                  child: ChatPanel(),
                ),
            ],
          );
        },
      ),
    );


  }
}


// class RoomDetailScreen extends StatelessWidget {
//   final String roomUrl;

//   const RoomDetailScreen({
//     super.key,
//     required this.roomUrl,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Room Details'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Room URL: $roomUrl',
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => context.go('/'),
//               child: const Text('Back to Home'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// } 