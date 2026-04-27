import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/completion_entry.dart';
import '../models/habit.dart';
import '../services/firestore_service.dart';
import '../utils/date_helpers.dart';
import '../widgets/empty_state.dart';
import '../widgets/habit_card.dart';
import 'add_edit_habit_screen.dart';
import 'habit_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final service = context.read<FirestoreService>();
    final today = DateTime.now();
    final todayString = toDateString(today);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Habits"),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMM d, y').format(today),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<Habit>>(
                stream: service.habitsStream(user.uid),
                builder: (context, habitsSnapshot) {
                  if (habitsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final habits = habitsSnapshot.data ?? [];
                  if (habits.isEmpty) {
                    return const EmptyState(
                      icon: Icons.emoji_events_outlined,
                      title: 'No habits yet',
                      subtitle: 'Tap the + button to create your first habit.',
                    );
                  }

                  return StreamBuilder<List<CompletionEntry>>(
                    stream: service.completionsStream(user.uid),
                    builder: (context, completionSnapshot) {
                      if (completionSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final completions = completionSnapshot.data ?? [];
                      final completionMap = <String, Set<String>>{};
                      for (final entry in completions) {
                        completionMap.putIfAbsent(entry.habitId, () => <String>{}).add(entry.date);
                      }

                      return ListView.separated(
                        itemCount: habits.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final habit = habits[index];
                          final dates = completionMap[habit.id] ?? <String>{};
                          final completedToday = dates.contains(todayString);
                          final stats = service.calculateStats(
                            completions
                                .where((entry) => entry.habitId == habit.id)
                                .toList(),
                          );

                          return HabitCard(
                            habit: habit,
                            completed: completedToday,
                            streak: stats.currentStreak,
                            onToggle: () => service.setCompletion(
                              uid: user.uid,
                              habitId: habit.id,
                              date: today,
                              completed: !completedToday,
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => HabitDetailScreen(habit: habit),
                              ),
                            ),
                            onEdit: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddEditHabitScreen(habit: habit),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
