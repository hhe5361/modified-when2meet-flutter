import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:my_web/models/room/model.dart';
import 'package:my_web/view/widgets/custom_button.dart';
import 'package:my_web/view/widgets/custom_test_field.dart';
import 'package:my_web/view/widgets/date_picker_widget.dart';
import 'package:my_web/view_model/home_view_model.dart';
import 'package:provider/provider.dart';

class CreateRoomForm extends StatefulWidget{
  const CreateRoomForm({super.key});

  @override
  State<CreateRoomForm> createState() => _CreateRoomFormState();
}

class _CreateRoomFormState extends State<CreateRoomForm> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _meetingDescriptionController = TextEditingController(); 
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  List<DateTime> _selectedDates = [];
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  Future<void> _pickTime(BuildContext context, TextEditingController controller, Function(TimeOfDay?) onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
        onTimeSelected(picked);
      });
    }
  }

  bool _isTimeAfter(TimeOfDay time1, TimeOfDay time2) {
    return time1.hour > time2.hour || 
           (time1.hour == time2.hour && time1.minute >= time2.minute);
  }

  void _createRoom() {
    if(_formKey.currentState!.validate()){
      if(_selectedDates.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("please select at least one date"))
        );
        return;
      }
    }
    
    if(_selectedStartTime == null || _selectedEndTime == null){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both start and end times.')),
        );
      return;
    }

    if(_isTimeAfter(_selectedStartTime!, _selectedEndTime!)){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time.')),
        );
      return;
    }

    //get view model instance by provider!!! listen false하면 리빌드는 안함. 
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);

    final List<VoteableDate> voteableDates = _selectedDates.map((date) => 
      VoteableDate(
        year: date.year,
        month: date.month,
        day: date.day
      )
    ).toList();
    
    //Time Region 선택하는 부분도 생겨야 함 + 온라인 여부 확인하는 것도 생겨야 함. 
    homeViewModel.createRoom(
        roomName: _roomNameController.text,
        timeRegion: 'Asia/Seoul', 
        startTime: _selectedStartTime!.hour * 60 + _selectedStartTime!.minute, // Convert to minutes from midnight
        endTime: _selectedEndTime!.hour * 60 + _selectedEndTime!.minute, // Convert to minutes from midnight
        isOnline: true, 
        voteableDates: voteableDates,
        onSuccess: (roomUrl) {
          context.go('/room/$roomUrl'); 
        },
      );

    
  }

  void _onDatesSelected(List<DateTime> dates) {
    setState(() {
      _selectedDates = dates;
    });
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _meetingDescriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meeting Room Name',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _roomNameController,
            labelText: 'e.g., Project Kickoff',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a room name';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Meeting Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _meetingDescriptionController,
            labelText: 'e.g., Discuss project goals and timelines',
            // Not required by API, so no validator
          ),
          const SizedBox(height: 24),
          const Text(
            'Availability',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          DatePickerWidget(
            onDatesSelected: _onDatesSelected,
            selectedDates: _selectedDates,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start Time',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _pickTime(context, _startTimeController, (time) => _selectedStartTime = time),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          controller: _startTimeController,
                          labelText: 'Select start time',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a start time';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'End Time',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _pickTime(context, _endTimeController, (time) => _selectedEndTime = time),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          controller: _endTimeController,
                          labelText: 'Select end time',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an end time';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              text: 'Create Meeting Room',
              onPressed: _createRoom,
              isLoading: homeViewModel.isLoading,
              width: 200,
              height: 50,
            ),
          ),
        ],
      ),
    );
  }
}
