import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:my_web/constants/enum/time_region.dart';
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
  int? _selectedStartTime;
  int? _selectedEndTime;
  String _selectedTimeRegion = 'Asia/Seoul';
  bool _isOnlineMeeting = false;

final List<String> _timeRegions = TimeRegion.values.map((e) => e.value).toList();

  void _validateAndSetTime(TextEditingController controller, int? Function() getCurrentTime, void Function(int) setTime) {
    final value = int.tryParse(controller.text);
    if (value == null || value < 0 || value > 23) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid hour (0-23)')),
      );
      return;
    }
    setTime(value);
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

    if(_selectedStartTime! >= _selectedEndTime!){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time.')),
        );
      return;
    }

    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);

    final List<VoteableDate> voteableDates = _selectedDates.map((date) => 
      VoteableDate(
        year: date.year,
        month: date.month,
        day: date.day
      )
    ).toList();
    
    
    homeViewModel.createRoom(
        roomName: _roomNameController.text,
        timeRegion: _selectedTimeRegion,
        startTime: _selectedStartTime!,
        endTime: _selectedEndTime!,
        isOnline: _isOnlineMeeting,
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
            labelText: 'eg. study room',
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
            labelText: 'eg. for study',
            // Not required by API, so no validator
          ),
          const SizedBox(height: 24),
          const Text(
            'Time Region',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedTimeRegion,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _timeRegions.map((String region) {
                return DropdownMenuItem<String>(
                  value: region,
                  child: Text(region),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTimeRegion = newValue;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Checkbox(
                value: _isOnlineMeeting,
                onChanged: (bool? value) {
                  setState(() {
                    _isOnlineMeeting = value ?? false;
                  });
                },
              ),
              const Text(
                'Online Meeting',
                style: TextStyle(fontSize: 16),
              ),
            ],
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
                      'Start Hour (0-23)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _startTimeController,
                      labelText: 'eg. 1',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter start hour';
                        }
                        final hour = int.tryParse(value);
                        if (hour == null || hour < 0 || hour > 23) {
                          return 'Enter hour (0-23)';
                        }
                        return null;
                      },
                      onChanged: (value) => _validateAndSetTime(
                        _startTimeController,
                        () => _selectedStartTime,
                        (time) => setState(() => _selectedStartTime = time),
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
                      'End Hour (0-23)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _endTimeController,
                      labelText: 'eg. 23',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter end hour';
                        }
                        final hour = int.tryParse(value);
                        if (hour == null || hour < 0 || hour > 23) {
                          return 'Enter hour (0-23)';
                        }
                        return null;
                      },
                      onChanged: (value) => _validateAndSetTime(
                        _endTimeController,
                        () => _selectedEndTime,
                        (time) => setState(() => _selectedEndTime = time),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (homeViewModel.errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      homeViewModel.errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (homeViewModel.successMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      homeViewModel.successMessage!,
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              text: 'Create Room',
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

  @override
  void dispose() {
    _roomNameController.dispose();
    _meetingDescriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

}
