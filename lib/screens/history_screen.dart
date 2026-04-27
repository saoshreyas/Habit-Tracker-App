import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/completion_entry.dart';
import '../models/habit.dart';
import '../services/firestore_service.dart';
import '../utils/date_helpers.dart';
import '../widgets/empty_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final service = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: StreamBuilder<List<Habit>>(
        stream: service.habitsStream(user.uid),
        builder: (context, habitSnapshot) {
          if (habitSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final habits = habitSnapshot.data ?? [];
          final habitMap = {for (final habit in habits) habit.id: habit};

          return StreamBuilder<List<CompletionEntry>>(
            stream: service.completionsStream(user.uid),
            builder: (context, completionSnapshot) {
              if (completionSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final entries = completionSnapshot.data ?? [];
              if (entries.isEmpty) {
                return const EmptyState(
                  icon: Icons.history_toggle_off,
                  title: 'No completion history yet',
                  subtitle: 'Your completed habits will appear here.',
                );
              }

              final grouped = <String, List<CompletionEntry>>{};
              for (final entry in entries) {
                grouped.putIfAbsent(entry.date, () => <CompletionEntry>[]).add(entry);
              }

              final dates = grouped.keys.toList()
                ..sort((a, b) => fromDateString(b).compareTo(fromDateString(a)));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final date = dates[index];
                  final dayEntries = grouped[date]!;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMM d, y').format(fromDateString(date)),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Divider(height: 18),
                          ...dayEntries.map((entry) {
                            final habit = habitMap[entry.habitId];
                            final label = habit == null
                                ? 'Deleted habit'
                                : '${habit.emoji} ${habit.name}';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, size: 18, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text(label),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
