import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/completion_entry.dart';
import '../models/habit.dart';
import '../services/firestore_service.dart';
import '../utils/date_helpers.dart';

class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen({super.key, required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final service = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(title: Text('${habit.emoji} ${habit.name}')),
      body: StreamBuilder<List<CompletionEntry>>(
        stream: service.completionsForHabitStream(uid, habit.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data ?? [];
          final stats = service.calculateStats(entries);
          final completedDates = entries.map((e) => e.date).toSet();

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _StatsCard(
                currentStreak: stats.currentStreak,
                longestStreak: stats.longestStreak,
                totalCompletions: stats.totalCompletions,
                color: habit.color,
              ),
              const SizedBox(height: 18),
              Text('Last 30 days', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _CompletionGrid(completedDates: completedDates, color: habit.color),
            ],
          );
        },
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletions,
    required this.color,
  });

  final int currentStreak;
  final int longestStreak;
  final int totalCompletions;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatValue(label: 'Current', value: currentStreak, color: color),
            _StatValue(label: 'Longest', value: longestStreak, color: color),
            _StatValue(label: 'Total', value: totalCompletions, color: color),
          ],
        ),
      ),
    );
  }
}

class _StatValue extends StatelessWidget {
  const _StatValue({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}

class _CompletionGrid extends StatelessWidget {
  const _CompletionGrid({required this.completedDates, required this.color});

  final Set<String> completedDates;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final days = List.generate(30, (index) {
      final date = DateTime.now().subtract(Duration(days: 29 - index));
      return date;
    });

    return GridView.builder(
      itemCount: days.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final date = days[index];
        final dateString = toDateString(date);
        final done = completedDates.contains(dateString);
        return Tooltip(
          message: DateFormat('EEE, MMM d').format(date),
          child: Container(
            decoration: BoxDecoration(
              color: done ? color : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: done ? Colors.white : Colors.black45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
