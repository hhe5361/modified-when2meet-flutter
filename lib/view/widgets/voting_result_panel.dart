import 'dart:math';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:my_web/view_model/room_detail_view_model.dart';
import 'package:my_web/models/room/response.dart';

class MeetingRecommendationScreen extends StatefulWidget {
  const MeetingRecommendationScreen({super.key});

  @override
  State<MeetingRecommendationScreen> createState() => _MeetingRecommendationScreenState();
}

class _MeetingRecommendationScreenState extends State<MeetingRecommendationScreen> {
  List<Map<String, dynamic>> _bestSlots = [];
  int? _selectedIndex;
  bool _isRandomizing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processMeetingSlots();
    });
  }

  void _processMeetingSlots() {
    final viewModel = Provider.of<RoomDetailViewModel>(context, listen: false);
    if (viewModel.voteTable == null) return;

    final candidates = _getBestMeetingSlots(viewModel.voteTable!);
    setState(() {
      _bestSlots = candidates;
      if (candidates.length > 1) {
        _selectedIndex = Random().nextInt(candidates.length);
      }
    });
  }

  void _rerollRandomIndex() {
    if (_bestSlots.length <= 1) return;
    setState(() {
      _isRandomizing = true;
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _selectedIndex = Random().nextInt(_bestSlots.length);
        _isRandomizing = false;
      });
    });
  }

  List<Map<String, dynamic>> _getBestMeetingSlots(Map<String, List<HourBlock>> voteTable) {
    List<Map<String, dynamic>> bestSlots = [];
    int maxPeople = 0;

    voteTable.forEach((date, slots) {
      int i = 0;
      while (i < slots.length) {
        List<String> commonUsers = List<String>.from(slots[i].user);
        int start = slots[i].hour;
        int end = start;

        int j = i + 1;
        while (j < slots.length && _isSameUsers(commonUsers, slots[j].user)) {
          end = slots[j].hour;
          j++;
        }

        if (commonUsers.isNotEmpty) {
          if (commonUsers.length > maxPeople) {
            maxPeople = commonUsers.length;
            bestSlots = [
              {
                "date": date,
                "startHour": start,
                "endHour": end + 1,
                "userCount": commonUsers.length,
                "userNames": commonUsers,
              }
            ];
          } else if (commonUsers.length == maxPeople) {
            bestSlots.add({
              "date": date,
              "startHour": start,
              "endHour": end + 1,
              "userCount": commonUsers.length,
              "userNames": commonUsers,
            });
          }
        }

        i = j;
      }
    });

    return bestSlots;
  }

  bool _isSameUsers(List<String> base, dynamic other) {
    if (other is! List) return false;
    final otherList = other.cast<String>();
    base.sort();
    otherList.sort();
    return ListEquality().equals(base, otherList);
  }

  String _weekdayString(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wen', 'Thur', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  String _formatDate(String isoDate) {
    final parsed = DateTime.parse(isoDate);
    return "${parsed.year}년 ${parsed.month}월 ${parsed.day}일 (${_weekdayString(parsed.weekday)})";
  }

  @override
  Widget build(BuildContext context) {
    if (_bestSlots.isEmpty) {
      return const Center(
        child: Text(
          "No voting results available yet.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          ..._bestSlots.asMap().entries.map((entry) {
            final index = entry.key;
            final slot = entry.value;

            final isSelected = index == _selectedIndex;
            final date = _formatDate(slot['date']);
            final start = slot['startHour'].toString().padLeft(2, '0');
            final end = slot['endHour'].toString().padLeft(2, '0');
            final count = slot['userCount'];
            final names = slot['userNames'] as List<String>;

            return Card(
              color: isSelected ? const Color(0xFFD8D5F2) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? Theme.of(context).primaryColor.withAlpha(50) : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              elevation: isSelected ? 4 : 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event_available,
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Best Option ${index + 1}",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Selected",
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(date, style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text("$start:00 - $end:00", style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.people, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                "$count people",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade200),
                    const SizedBox(height: 12),
                    Text(
                      "Available Participants",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: names.map((name) => Chip(
                        label: Text(name),
                        backgroundColor: Theme.of(context).primaryColor.withAlpha(26),
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        avatar: CircleAvatar(
                          radius: 12,
                          backgroundColor: Theme.of(context).primaryColor.withAlpha(26),
                          child: Text(
                            name[0].toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (_bestSlots.length > 1) ...[
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  if (_isRandomizing)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        "Finding the best time...",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: _isRandomizing ? null : _rerollRandomIndex,
                    icon: const Icon(Icons.shuffle),
                    label: const Text("Randomize Selection"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
