import 'package:flutter/material.dart';
import 'package:my_web/models/room/model.dart';
import 'package:intl/intl.dart';
import 'package:my_web/models/room/response.dart';
import 'package:my_web/models/user/response.dart';

class TimeGridWidget extends StatefulWidget {
  final Room roomInfo;
  final Map<String, List<HourBlock>> voteTable;
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

  late int _maxVoters;

  @override
  void initState() {
    super.initState();
    _maxVoters = _calculateMaxVoters();
  }

  int _calculateMaxVoters() {
    int maxCount = 0;
    for (final date in widget.votableDates) {
      final hours = widget.voteTable[date] ?? [];
      for (final hour in hours) {
        final voters = widget.getVotersForSlot(date, hour.hour);
        if (voters.length > maxCount) {
          maxCount = voters.length;
        }
      }
    }
    return maxCount;
  }

  String _getDateForColumn(int columnIndex) => widget.votableDates[columnIndex];

  int _getHourForRow(int rowIndex) => widget.roomInfo.startTime + rowIndex;

  String _formatHour(int hour) {
    final DateTime time = DateTime(2000, 1, 1, hour);
    return DateFormat('h:mm a').format(time);
  }

  int get _hoursInGrid =>
      widget.roomInfo.endTime - widget.roomInfo.startTime + 1;
  int get _numColumns => widget.votableDates.length;
  int get _numRows => _hoursInGrid;

  bool _isCellInDragSelection(int row, int col) {
    if (_dragStartOffset == null || _dragCurrentOffset == null) return false;

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

    final int minRow = startRow < endRow ? startRow : endRow;
    final int maxRow = startRow > endRow ? startRow : endRow;
    final int minCol = startCol < endCol ? startCol : endCol;
    final int maxCol = startCol > endCol ? startCol : endCol;

    final String initialDate = _getDateForColumn(startCol);
    bool initialSelected =
        widget.selectedTimeSlots[initialDate]?[startRow]?.selected ?? false;

    for (int c = minCol; c <= maxCol; c++) {
      for (int r = minRow; r <= maxRow; r++) {
        final String date = _getDateForColumn(c);
        final selected = widget.selectedTimeSlots[date]?[r]?.selected ?? false;
        if (selected == initialSelected) {
          widget.onTimeSlotToggled(date, r);
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

    const double cellHeight = 48.0;
    const double cellWidth = 120.0;
    const double timeColumnWidth = 80.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth =
            timeColumnWidth + (cellWidth * _numColumns) + 16.0;
        final bool needsScroll = totalWidth > constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: needsScroll ? totalWidth : constraints.maxWidth - 16.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                              DateFormat(
                                'EEE, MMM d',
                              ).format(DateTime.parse(date)),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Grid
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
                            // Time column
                            SizedBox(
                              width: timeColumnWidth,
                              height: cellHeight,
                              child: Center(child: Text(_formatHour(hour))),
                            ),
                            ...List.generate(_numColumns, (colIndex) {
                              final date = _getDateForColumn(colIndex);
                              final isSelected =
                                  widget
                                      .selectedTimeSlots[date]?[rowIndex]
                                      ?.selected ??
                                  false;
                              final isDraggingOver = _isCellInDragSelection(
                                rowIndex,
                                colIndex,
                              );
                              final voters = widget.getVotersForSlot(
                                date,
                                hour,
                              );
                              final voteCount = voters.length;

                              final double intensity =
                                  (_maxVoters > 0)
                                      ? voteCount / _maxVoters
                                      : 0.0;
                              final Color baseColor =
                                  Theme.of(context).primaryColor;
                              final Color fillColor =
                                  isSelected
                                      ? baseColor
                                      : isDraggingOver
                                      ? baseColor.withOpacity(0.3)
                                      : Color.lerp(
                                        Colors.white,
                                        baseColor.withOpacity(0.6),
                                        intensity,
                                      )!;

                              return GestureDetector(
                                onPanDown:
                                    widget.isLoggedIn
                                        ? (_) => setState(() {
                                          _dragStartOffset = Offset(
                                            colIndex.toDouble(),
                                            rowIndex.toDouble(),
                                          );
                                          _dragCurrentOffset = Offset(
                                            colIndex.toDouble(),
                                            rowIndex.toDouble(),
                                          );
                                        })
                                        : null,
                                onPanUpdate:
                                    widget.isLoggedIn
                                        ? (details) {
                                          final renderBox =
                                              context.findRenderObject()
                                                  as RenderBox;
                                          final local = renderBox.globalToLocal(
                                            details.globalPosition,
                                          );
                                          final int currentCol = ((local.dx -
                                                      timeColumnWidth) /
                                                  cellWidth)
                                              .floor()
                                              .clamp(0, _numColumns - 1);
                                          final int currentRow = (local.dy /
                                                  cellHeight)
                                              .floor()
                                              .clamp(0, _numRows - 1);

                                          if (_dragCurrentOffset?.dx.toInt() !=
                                                  currentCol ||
                                              _dragCurrentOffset?.dy.toInt() !=
                                                  currentRow) {
                                            setState(() {
                                              _dragCurrentOffset = Offset(
                                                currentCol.toDouble(),
                                                currentRow.toDouble(),
                                              );
                                            });
                                          }
                                        }
                                        : null,
                                onPanEnd:
                                    widget.isLoggedIn
                                        ? (_) => _applyDragSelection()
                                        : null,
                                onTap:
                                    widget.isLoggedIn
                                        ? () => widget.onTimeSlotToggled(
                                          date,
                                          rowIndex,
                                        )
                                        : null,
                                child: MouseRegion(
                                  cursor:
                                      widget.isLoggedIn
                                          ? SystemMouseCursors.click
                                          : SystemMouseCursors.basic,
                                  child: Tooltip(
                                    message:
                                        voters.isNotEmpty
                                            ? 'Voted by: ${voters.join(', ')}'
                                            : 'No one has voted for this slot yet.',
                                    waitDuration: const Duration(
                                      milliseconds: 500,
                                    ),
                                    child: Container(
                                      width: cellWidth,
                                      height: cellHeight,
                                      decoration: BoxDecoration(
                                        color: fillColor,
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Text(
                                          voteCount > 0 ? '$voteCount' : '',
                                          style: TextStyle(
                                            color:
                                                isSelected || intensity > 0.4
                                                    ? Colors.white
                                                    : Colors.black,
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
