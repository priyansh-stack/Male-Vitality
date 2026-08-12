import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/models/mental_wellness/mood_entry.dart';
import '../../../core/theme/app_theme.dart';

class MoodCalendarWidget extends StatefulWidget {
  final List<MoodEntry> entries;
  final Function(DateTime) onDaySelected;

  const MoodCalendarWidget({
    super.key,
    required this.entries,
    required this.onDaySelected,
  });

  @override
  State<MoodCalendarWidget> createState() => _MoodCalendarWidgetState();
}

class _MoodCalendarWidgetState extends State<MoodCalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mood Calendar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap a day to see mood entries',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now(),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                widget.onDaySelected(selectedDay);
              },
              calendarStyle: CalendarStyle(
                markersMaxCount: 1,
                markerDecoration: const BoxDecoration(
                  color: AppTheme.primaryTeal,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppTheme.primaryTeal,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final entriesForDay = widget.entries.where((entry) =>
                    entry.timestamp.day == date.day &&
                    entry.timestamp.month == date.month &&
                    entry.timestamp.year == date.year
                  ).toList();

                  if (entriesForDay.isEmpty) return null;

                  final avgMood = entriesForDay.map((e) => e.moodRating).reduce((a, b) => a + b) / entriesForDay.length;
                  final color = _getMoodColor(avgMood.round());

                  return Positioned(
                    bottom: 2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              onFormatChanged: (format) {},
              availableGestures: AvailableGestures.all,
            ),
            const SizedBox(height: 12),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Great', AppTheme.healthyGreen),
        const SizedBox(width: 16),
        _buildLegendItem('Good', AppTheme.primaryTeal),
        const SizedBox(width: 16),
        _buildLegendItem('Okay', AppTheme.warningOrange),
        const SizedBox(width: 16),
        _buildLegendItem('Low', AppTheme.dangerRed),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Color _getMoodColor(int rating) {
    if (rating >= 8) return AppTheme.healthyGreen;
    if (rating >= 6) return AppTheme.primaryTeal;
    if (rating >= 4) return AppTheme.warningOrange;
    return AppTheme.dangerRed;
  }
}