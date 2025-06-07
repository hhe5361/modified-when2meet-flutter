import 'package:flutter/material.dart';
import 'package:my_web/constants/enum/time_region.dart';
import 'package:my_web/core/util/app.dart';
import 'package:my_web/view/widgets/custom_button.dart';
import 'package:my_web/view/widgets/login_dialog.dart';
import 'package:my_web/view/widgets/notice_panel.dart';
import 'package:my_web/view/widgets/time_grid_widget.dart';
import 'package:my_web/view/widgets/voting_result_panel.dart';
import 'package:my_web/view_model/notice_view_model.dart';
import 'package:my_web/view_model/room_detail_view_model.dart';
import 'package:my_web/view_model/session_service.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class RoomDetailScreen extends StatefulWidget {
  final String roomUrl;

  const RoomDetailScreen({super.key, required this.roomUrl});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  bool _showVotingResult = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoomDetailViewModel>(
        context,
        listen: false,
      ).init(widget.roomUrl);
      Provider.of<NoticeViewModel>(context, listen: false).init(widget.roomUrl);
    });
  }

  void _toggleView() {
    setState(() {
      _showVotingResult = !_showVotingResult;
    });
  }

  void _showLoginDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (BuildContext dialogCtx) {
        return LoginDialog(
          onLogin: (name, password) {
            final SessionService session = Provider.of<SessionService>(
              context,
              listen: false,
            );
            session.login(
              roomUrl: widget.roomUrl,
              name: name,
              password: password,
              timeRegion: TimeRegion.asiaSeoul,
            ); //time region 부분 고쳐야함.
            Navigator.of(dialogCtx).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => context.go('/'),
          child: const Text('PlanWhen'),
        ),
        centerTitle: false,
        actions: [
          Consumer<SessionService>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoggedIn) {
                return Row(
                  children: [
                    Text('Welcome, ${viewModel.currentUser?.name ?? ''}'),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        viewModel.logout();
                        context
                            .read<RoomDetailViewModel>()
                            .setSelectedTimeSlot();

                        AppUtils.showSnackBar(
                          context,
                          'Logged out successfully!',
                        );
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                );
              } else {
                return TextButton(
                  onPressed: () => _showLoginDialog(context),
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<RoomDetailViewModel>(
        builder: (context, viewModel, child) {
          if ((viewModel.isLoading ?? false) && viewModel.roomInfo == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppUtils.showSnackBar(
                context,
                viewModel!.errorMessage!,
                err: true,
              );
              viewModel.clearMessages();
            });
          }
          if (viewModel.successMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppUtils.showSnackBar(context, viewModel!.successMessage!);
              viewModel.clearMessages();
            });
          }

          if (viewModel.roomInfo == null) {
            return const Center(child: Text('Failed to load room details.'));
          }

          final screenWidth = MediaQuery.of(context).size.width;
          final bool showChatPanel = screenWidth > 900;

          return Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  flex: showChatPanel ? 3 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(
                            0.08,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    viewModel.roomInfo!.name,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _toggleView,
                                  icon: Icon(
                                    _showVotingResult
                                        ? Icons.grid_view
                                        : Icons.analytics,
                                  ),
                                  label: Text(
                                    _showVotingResult
                                        ? 'Show Time Grid'
                                        : 'Show Voting Result',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Vote on the best time for "${viewModel.roomInfo!.name}"',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          child: SingleChildScrollView(
                            child: Center(
                              child: Container(
                                width: AppUtils.getResponsiveWidth(
                                  context,
                                  desktopWidth: 1200,
                                  tabletWidth: 700,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      showChatPanel ? 900 : double.infinity,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 32),
                                    if (_showVotingResult)
                                      const MeetingRecommendationScreen()
                                    else
                                      Consumer<SessionService>(
                                        builder: (context, session, child) {
                                          final isLoggedIn = session.isLoggedIn;
                                          return Column(
                                            children: [
                                              TimeGridWidget(
                                                roomInfo: viewModel.roomInfo!,
                                                voteTable:
                                                    viewModel.voteTable ?? {},
                                                selectedTimeSlots:
                                                    viewModel
                                                        .selectedTimeSlots!,
                                                onTimeSlotToggled:
                                                    viewModel.toggleTimeSlot,
                                                getVotersForSlot:
                                                    viewModel.getVotersForSlot,
                                                isLoggedIn: isLoggedIn,
                                              ),
                                              const SizedBox(height: 32),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: CustomButton(
                                                  text: 'Vote',
                                                  onPressed:
                                                      isLoggedIn
                                                          ? () => viewModel
                                                              .voteTime(
                                                                widget.roomUrl,
                                                              )
                                                          : () {},
                                                  isLoading:
                                                      viewModel.isLoading,
                                                  width: 150,
                                                  height: 50,
                                                  color:
                                                      isLoggedIn
                                                          ? Theme.of(
                                                            context,
                                                          ).primaryColor
                                                          : Colors.grey,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(
                  color: Colors.grey.withAlpha(150), // 원하는 연한 회색
                  thickness: 1,
                  width: 20,
                ),
                if (showChatPanel)
                  Expanded(
                    flex: 1,
                    child: NoticePanel(roomUrl: widget.roomUrl),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
