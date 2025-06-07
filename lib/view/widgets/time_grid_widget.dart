import 'package:flutter/material.dart';
import 'package:my_web/models/room/model.dart';
import 'package:intl/intl.dart';
import 'package:my_web/models/room/response.dart';
import 'package:my_web/models/user/response.dart';

class TimeGridWidget extends StatefulWidget {
  final Room roomInfo;
  final Map<String,List<HourBlock>> voteTable;
  final Map<String, List<TimeSlot>> selectedTimeSlots;
  final Function(String date, int hour) onTimeSlotToggled;
  final List<String> Function(String date, int hour) getVotersForSlot;
  final bool isLoggedIn;
  final List<String> votableDates;

  TimeGridWidget({
    super.key,
    required this.roomInfo,
    required this.voteTable,
    required this.selectedTimeSlots,
    required this.onTimeSlotToggled,
    required this.getVotersForSlot,
    required this.isLoggedIn,
  }) : votableDates = voteTable.keys.toList()..sort();

  @override
  State<TimeGridWidget> createState() => _TimeGridWidgetState();
}

class _TimeGridWidgetState extends State<TimeGridWidget> {
  Offset? _dragStartOffset;
  Offset? _dragCurrentOffset;

  String _getDateForColumn(int columnIndex) {
    final dateString = widget.votableDates[columnIndex];
    return dateString;
  }

  int _getHourForRow(int rowIndex) {
    return widget.roomInfo.startTime + rowIndex;
  }

  String _formatHour(int hour) {
    final DateTime time = DateTime(2000, 1, 1, hour);
    return DateFormat('h:mm a').format(time);
  }

  int get _hoursInGrid => widget.roomInfo.endTime - widget.roomInfo.startTime + 1;

  int get _numColumns => widget.votableDates.length;

  int get _numRows => _hoursInGrid;

  // Determine if a cell is within the current drag selection
  bool _isCellInDragSelection(int row, int col) {
    if (_dragStartOffset == null || _dragCurrentOffset == null) {
      return false;
    }

    final int startRow = _dragStartOffset!.dy.toInt();
    final int startCol = _dragStartOffset!.dx.toInt();
    final int endRow = _dragCurrentOffset!.dy.toInt();
    final int endCol = _dragCurrentOffset!.dx.toInt();

    final int minRow = startRow < endRow ? startRow : endRow;
    final int maxRow = startRow > endRow ? startRow : endRow;
    final int minCol = startCol < endCol ? startCol : endCol;
    final int maxCol = startCol > endCol ? startCol : endCol;

    return row >= minRow && row <= maxRow && col >= minCol && col <= maxCol;
  }

  void _applyDragSelection() {
    if (_dragStartOffset == null || _dragCurrentOffset == null) return;

    final int startRow = _dragStartOffset!.dy.toInt();
    final int startCol = _dragStartOffset!.dx.toInt();
    final int endRow = _dragCurrentOffset!.dy.toInt();
    final int endCol = _dragCurrentOffset!.dx.toInt();

    print("Start Row: $startRow, End Row: $endRow");
    print("Start Col: $startCol, End Col: $endCol");

    final int minRow = startRow < endRow ? startRow : endRow;
    final int maxRow = startRow > endRow ? startRow : endRow;
    final int minCol = startCol < endCol ? startCol : endCol;
    final int maxCol = startCol > endCol ? startCol : endCol;

    // Determine if we are selecting or deselecting based on the first cell dragged
    final String initialDate = _getDateForColumn(startCol);
    final int initialHour = _getHourForRow(startRow);
    print("Initial Date: $initialDate");
    print("SelectedTimeSlots for initialDate: ${widget.selectedTimeSlots[initialDate]?.map((slot) => 'TimeSlot(hour: ${slot.hour}, selected: ${slot.selected})').toList()}");
    print("Min Col: $minCol, Max Col: $maxCol , Min Row : $minRow , Max Row : $maxRow");
    bool initialSelectionState = widget.selectedTimeSlots[initialDate]?[startRow]?.selected ?? false;

    for (int c = minCol; c <= maxCol; c++) {
      for (int r = minRow; r <= maxRow; r++) {
        final String date = _getDateForColumn(c);
        final int hour = _getHourForRow(r);
        print("$hour is the right?" );
        if (initialSelectionState) {
          if (widget.selectedTimeSlots[date]?[r]?.selected ?? false) {
            widget.onTimeSlotToggled(date, r);
          }
        } else {
          if (!(widget.selectedTimeSlots[date]?[r]?.selected ?? false)) {
            widget.onTimeSlotToggled(date, r);
      }
        }
      }
    }
    print("SelectedTimeSlots for result: ${widget.selectedTimeSlots[initialDate]?.map((slot) => 'TimeSlot(hour: ${slot.hour}, selected: ${slot.selected})').toList()}");


    setState(() {
      _dragStartOffset = null;
      _dragCurrentOffset = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.votableDates.isEmpty || _hoursInGrid <= 0) {
      return const Center(child: Text('No votable dates or times available.'));
    }

    final double cellHeight = 48.0;
    final double cellWidth = 120.0; 
    final double timeColumnWidth = 80.0; 

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate total width needed with padding
        final double totalWidth = timeColumnWidth + (cellWidth * _numColumns) + 16.0; // Add padding
        final bool needsScroll = totalWidth > constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: needsScroll ? totalWidth : constraints.maxWidth - 16.0, // Account for padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row (Time + Dates)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Add this
                      children: [
                        SizedBox(
                          width: timeColumnWidth,
                          height: cellHeight,
                          child: const Center(
                            child: Text(
                              'Time',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        ...List.generate(_numColumns, (colIndex) {
                          final date = _getDateForColumn(colIndex);
                          return Container(
                            width: cellWidth,
                            height: cellHeight,
                            alignment: Alignment.center,
                            child: Text(
                              DateFormat('EEE, MMM d').format(DateTime.parse(date)),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Time Grid Body
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: List.generate(_numRows, (rowIndex) {
                        final hour = _getHourForRow(rowIndex);
                        return Row(
                          children: [
                            // Time Column
                            SizedBox(
                              width: timeColumnWidth,
                              height: cellHeight,
                              child: Center(
                                child: Text(_formatHour(hour)),
                              ),
                            ),
                            // Date/Time Cells
                            ...List.generate(_numColumns, (colIndex) {
                              final date = _getDateForColumn(colIndex);
                              final bool isSelected = widget.selectedTimeSlots[date] != null && 
                                  rowIndex >= 0 &&
                                  rowIndex < widget.selectedTimeSlots[date]!.length &&
                                  widget.selectedTimeSlots[date]![rowIndex].selected;
                              final bool isDraggingOver = _isCellInDragSelection(rowIndex, colIndex);

                              // Get voters for this specific slot
                              final List<String> voters = widget.getVotersForSlot(date, hour);

                              return GestureDetector(
                                onPanDown: widget.isLoggedIn
                                    ? (details) {
                                        setState(() {
                                          _dragStartOffset = Offset(colIndex.toDouble(), rowIndex.toDouble());
                                          _dragCurrentOffset = Offset(colIndex.toDouble(), rowIndex.toDouble());
                                        });
                                      }
                                    : null,
                                onPanUpdate: widget.isLoggedIn
                                    ? (details) {
                                        final RenderBox renderBox = context.findRenderObject() as RenderBox;
                                        final localPosition = renderBox.globalToLocal(details.globalPosition);

                                        // Calculate which cell the drag is currently over
                                        final int currentCol = ((localPosition.dx - timeColumnWidth) / cellWidth).floor().clamp(0, _numColumns - 1);
                                        final int currentRow = (localPosition.dy / cellHeight).floor().clamp(0, _numRows - 1);

                                        if (_dragCurrentOffset?.dx.toInt() != currentCol || _dragCurrentOffset?.dy.toInt() != currentRow) {
                                          setState(() {
                                            _dragCurrentOffset = Offset(currentCol.toDouble(), currentRow.toDouble());
                                          });
                                        }
                                      }
                                    : null,
                                onPanEnd: widget.isLoggedIn ? (details) => _applyDragSelection() : null,
                                onTap: widget.isLoggedIn
                                    ? () {
                                        widget.onTimeSlotToggled(date, rowIndex);
                                      }
                                    : null,
                                child: MouseRegion(
                                  cursor: widget.isLoggedIn ? SystemMouseCursors.click : SystemMouseCursors.basic,
                                  child: Tooltip(
                                    message: voters.isNotEmpty
                                        ? 'Voted by: ${voters.join(', ')}'
                                        : 'No one has voted for this slot yet.',
                                    waitDuration: const Duration(milliseconds: 500),
                                    child: Container(
                                      width: cellWidth,
                                      height: cellHeight,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Theme.of(context).primaryColor.withAlpha(179)
                                            : isDraggingOver
                                                ? Theme.of(context).primaryColor.withAlpha(77)
                                                : Colors.white,
                                        border: Border.all(color: Colors.grey.shade200),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Text(
                                          voters.isEmpty ? '' : '${voters.length}',
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
