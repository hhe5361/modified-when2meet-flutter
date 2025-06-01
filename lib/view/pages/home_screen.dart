import 'package:flutter/material.dart';
import 'package:my_web/core/util/app.dart';
import 'package:my_web/view/widgets/create_room_form.dart';
import 'package:my_web/view_model/home_view_model.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget{
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meet Up'),
        centerTitle: true      
        ),
      body: Consumer<HomeViewModel>(
        builder: (ctx,  viewModel , child) {
          if(viewModel.errorMessage != null){
            WidgetsBinding.instance.addPostFrameCallback((_){
              AppUtils.showSnackBar(ctx, viewModel.errorMessage! , err: true);
              viewModel.clearMessages();
            });
          }
          if ( viewModel.successMessage != null){
            WidgetsBinding.instance.addPostFrameCallback((_){
              AppUtils.showSnackBar(ctx, viewModel.successMessage!, err: false);
              viewModel.clearMessages();
            });
          }

          //view return
          return SingleChildScrollView(
            child: Center(
              child: Container(
                width: AppUtils.getResponsiveWidth(ctx),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                        const Text(
                      'Create a new meeting room',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Set your availability for the meeting',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    CreateRoomForm(),
                  ],
                ),
              ),
            ),
          );
        }),
    );
  }

}