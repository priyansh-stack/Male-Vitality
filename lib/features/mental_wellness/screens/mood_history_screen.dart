import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/bloc/mental_wellness/mood_bloc/mood_bloc.dart';
import '../../../core/models/mental_wellness/mood_entry.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/mood_calendar_widget.dart';

class MoodHistoryScreen extends StatefulWidget {
  final String userId;

  const MoodHistoryScreen({super.key, required this.userId});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  int _selectedDays = 30;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    context.read<MoodBloc>().add(
      LoadMoodHistoryEvent(
        userId: widget.userId,
        days: _selectedDays,
      ),
    );
  }

  void _goBack() {
    context.go('/wellness?userId=${widget.userId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Mood History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        actions: [
          DropdownButton<int>(
            value: _selectedDays,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedDays = value;
                  _loadHistory();
                });
              }
            },
            items: const [
              DropdownMenuItem(value: 7, child: Text('7 Days')),
              DropdownMenuItem(value: 30, child: Text('30 Days')),
              DropdownMenuItem(value: 90, child: Text('90 Days')),
              DropdownMenuItem(value: 365, child: Text('1 Year')),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<MoodBloc, MoodState>(
        builder: (context, state) {
          if (state is MoodLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MoodErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadHistory,
                    child: const Text('Retry'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _goBack,
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (state is MoodHistoryLoadedState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsSummary(state.entries),
                  const SizedBox(height: 24),
                  MoodCalendarWidget(
                    entries: state.entries,
                    onDaySelected: (date) {
                      _showDayDetails(context, date, state.entries);
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildRecentEntries(state.entries),
                ],
              ),
            );
          }

          return const Center(child: Text('No mood data available'));
        },
      ),
    );
  }

  Widget _buildStatsSummary(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No mood entries yet')),
        ),
      );
    }

    final avgMood = entries.map((e) => e.moodRating).reduce((a, b) => a + b) / entries.length;
    final highestMood = entries.map((e) => e.moodRating).reduce((a, b) => a > b ? a : b);
    final lowestMood = entries.map((e) => e.moodRating).reduce((a, b) => a < b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Average', '${avgMood.toStringAsFixed(1)}', Icons.trending_up),
            _buildStatItem('Highest', '$highestMood', Icons.arrow_upward, AppTheme.healthyGreen),
            _buildStatItem('Lowest', '$lowestMood', Icons.arrow_downward, AppTheme.dangerRed),
            _buildStatItem('Entries', '${entries.length}', Icons.list),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, [Color? color]) {
    return Column(
      children: [
        Icon(icon, color: color ?? AppTheme.primaryTeal, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildRecentEntries(List<MoodEntry> entries) {
    final recent = entries.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Entries',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...recent.map((entry) => _buildEntryCard(entry)),
      ],
    );
  }

  Widget _buildEntryCard(MoodEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getMoodColor(entry.moodRating),
          child: Text(
            entry.moodRating.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          _formatDate(entry.timestamp),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.triggers.isNotEmpty)
              Wrap(
                spacing: 4,
                children: entry.triggers.map((t) {
                  return Chip(
                    label: Text(t, style: const TextStyle(fontSize: 10)),
                    padding: const EdgeInsets.all(0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            if (entry.notes != null)
              Text(
                entry.notes!,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (entry.phq2Score != null)
              Text(
                'PHQ-2: ${entry.phq2Score}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            if (entry.gad2Score != null)
              Text(
                'GAD-2: ${entry.gad2Score}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(int rating) {
    if (rating >= 8) return AppTheme.healthyGreen;
    if (rating >= 6) return AppTheme.primaryTeal;
    if (rating >= 4) return AppTheme.warningOrange;
    return AppTheme.dangerRed;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDayDetails(BuildContext context, DateTime date, List<MoodEntry> entries) {
    final dayEntries = entries.where((e) =>
      e.timestamp.day == date.day &&
      e.timestamp.month == date.month &&
      e.timestamp.year == date.year
    ).toList();

    if (dayEntries.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(date),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ...dayEntries.map((entry) => ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: _getMoodColor(entry.moodRating),
                  child: Text(
                    entry.moodRating.toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                title: Text(entry.notes ?? 'No notes'),
                subtitle: Text(
                  '${entry.triggers.join(', ')}',
                  style: const TextStyle(fontSize: 12),
                ),
              )),
            ],
          ),
        );
      },
    );
  }
}