import 'package:flutter/material.dart';
import 'package:my_web/models/room/model.dart';
import 'package:intl/intl.dart';

class TimeGridWidget extends StatefulWidget {
  final Room roomInfo;
  final List<VoteableDate> votableDates;
  final List<Map<String, dynamic>> allUsersData;
  final Set<String> selectedTimeSlots;
  final Function(DateTime date, int hour) onTimeSlotToggled;
  final List<String> Function(DateTime date, int hour) getVotersForSlot;
  final bool isLoggedIn;

  const TimeGridWidget({
    super.key,
    required this.roomInfo,
    required this.votableDates,
    required this.allUsersData,
    required this.selectedTimeSlots,
    required this.onTimeSlotToggled,
    required this.getVotersForSlot,
    required this.isLoggedIn,
  });

  @override
  State<TimeGridWidget> createState() => _TimeGridWidgetState();
}

class _TimeGridWidgetState extends State<TimeGridWidget> {
  Offset? _dragStartOffset;
  Offset? _dragCurrentOffset;

  // Helper to get the date for a given column index
  DateTime _getDateForColumn(int columnIndex) {
    final votableDate = widget.votableDates[columnIndex];
    return DateTime(votableDate.year, votableDate.month, votableDate.day);
  }

  // Helper to get the hour for a given row index
  int _getHourForRow(int rowIndex) {
    return widget.roomInfo.startTime + rowIndex;
  }

  // Helper to get the formatted time string for a given hour
  String _formatHour(int hour) {
    final DateTime time = DateTime(2000, 1, 1, hour); // Use a dummy date
    return DateFormat('h:mm a').format(time);
  }

  // Calculate the number of hours in the grid
  int get _hoursInGrid => widget.roomInfo.endTime - widget.roomInfo.startTime;

  // Calculate the number of columns (dates)
  int get _numColumns => widget.votableDates.length;

  // Calculate the number of rows (time slots)
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

  // Apply the selected time slots based on the drag
  void _applyDragSelection() {
    if (_dragStartOffset == null || _dragCurrentOffset == null) return;

    final int startRow = _dragStartOffset!.dy.toInt();
    final int startCol = _dragStartOffset!.dx.toInt();
    final int endRow = _dragCurrentOffset!.dy.toInt();
    final int endCol = _dragCurrentOffset!.dx.toInt();

    final int minRow = startRow < endRow ? startRow : endRow;
    final int maxRow = startRow > endRow ? startRow : endRow;
    final int minCol = startCol < endCol ? startCol : endCol;
    final int maxCol = startCol > endCol ? startCol : endCol;

    // Determine if we are selecting or deselecting based on the first cell dragged
    bool initialSelectionState = false;
    final DateTime initialDate = _getDateForColumn(startCol);
    final int initialHour = _getHourForRow(startRow);
    final String initialKey = '${initialDate.toIso8601String().split('T')[0]}_$initialHour';
    initialSelectionState = widget.selectedTimeSlots.contains(initialKey);

    for (int c = minCol; c <= maxCol; c++) {
      for (int r = minRow; r <= maxRow; r++) {
        final DateTime date = _getDateForColumn(c);
        final int hour = _getHourForRow(r);
        final String key = '${date.toIso8601String().split('T')[0]}_$hour';

        if (initialSelectionState) {
          // If the initial cell was selected, we are deselecting the dragged range
          if (widget.selectedTimeSlots.contains(key)) {
            widget.onTimeSlotToggled(date, hour);
          }
        } else {
          // If the initial cell was unselected, we are selecting the dragged range
          if (!widget.selectedTimeSlots.contains(key)) {
            widget.onTimeSlotToggled(date, hour);
          }
        }
      }
    }

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
    final double cellWidth = 120.0; // Adjust for responsiveness
    final double timeColumnWidth = 80.0; // Width for the 'Time' column

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic cell width based on available space
        final double availableWidthForDates = constraints.maxWidth - timeColumnWidth;
        final double dynamicCellWidth = availableWidthForDates / _numColumns;
        final double effectiveCellWidth = dynamicCellWidth < cellWidth ? dynamicCellWidth : cellWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row (Time + Dates)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
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
                      width: effectiveCellWidth,
                      height: cellHeight,
                      alignment: Alignment.center,
                      child: Text(
                        DateFormat('EEE, MMM d').format(date),
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
                        final String cellKey = '${date.toIso8601String().split('T')[0]}_$hour';
                        final bool isSelected = widget.selectedTimeSlots.contains(cellKey);
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
                                  final int currentCol = ((localPosition.dx - timeColumnWidth) / effectiveCellWidth).floor().clamp(0, _numColumns - 1);
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
                                  widget.onTimeSlotToggled(date, hour);
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
                                width: effectiveCellWidth,
                                height: cellHeight,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor.withOpacity(0.7)
                                      : isDraggingOver
                                          ? Theme.of(context).primaryColor.withOpacity(0.3)
                                          : Colors.white,
                                  border: Border.all(color: Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(4), // Rounded corners for cells
                                ),
                                child: Center(
                                  child: Text(
                                    voters.isEmpty ? '' : '${voters.length}', // Show count of voters
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
        );
      },
    );
  }
}
