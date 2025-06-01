import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DatePickerWidget extends StatefulWidget {
  final Function(List<DateTime>) onDatesSelected;
  final List<DateTime> selectedDates;

  const DatePickerWidget({
    super.key,
    required this.onDatesSelected,
    required this.selectedDates,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    // Initialize _selectedDates with any pre-selected dates
    // For now, it will be empty as per the form's initial state
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      if (widget.selectedDates.contains(selectedDay)) {
        widget.selectedDates.remove(selectedDay);
      } else {
        widget.selectedDates.add(selectedDay);
      }
      widget.onDatesSelected(widget.selectedDates);
    });
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _rangeStart = start;
      _rangeEnd = end;
      _focusedDay = focusedDay;

      widget.selectedDates.clear();
      if (start != null && end != null) {
        for (DateTime d = start; d.isBefore(end.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
          widget.selectedDates.add(d);
        }
      } else if (start != null) {
        widget.selectedDates.add(start);
      }
      widget.onDatesSelected(widget.selectedDates);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double calendarWidth = constraints.maxWidth;
        final bool isLargeScreen = calendarWidth > 700;

        return TableCalendar(
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2025, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => widget.selectedDates.contains(day),
          rangeStartDay: _rangeStart,
          rangeEndDay: _rangeEnd,
          onDaySelected: _onDaySelected,
          onRangeSelected: _onRangeSelected,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).primaryColor),
            rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).primaryColor),
            headerPadding: const EdgeInsets.symmetric(vertical: 8.0),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            rangeStartDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            rangeEndDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            withinRangeDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            outsideDaysVisible: false,
          ),
          rowHeight: isLargeScreen ? 52.0 : 42.0, // Adjust row height for responsiveness
          daysOfWeekHeight: isLargeScreen ? 28.0 : 22.0, // Adjust days of week height
          availableGestures: AvailableGestures.horizontalSwipe,
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              
              // Custom styling for default days
              return Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(color: Colors.black),
                ),
              );
            },
            selectedBuilder: (context, day, focusedDay) {
              return Container(
                margin: const EdgeInsets.all(6.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${day.day}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
            todayBuilder: (context, day, focusedDay) {
              return Container(
                margin: const EdgeInsets.all(6.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${day.day}',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              );
            },
          ),
        );
      },
    );
  }
}