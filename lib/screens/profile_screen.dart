import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/completion_entry.dart';
import '../models/habit.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/empty_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final firestoreService = context.read<FirestoreService>();
    final authService = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: StreamBuilder<List<Habit>>(
        stream: firestoreService.habitsStream(user.uid),
        builder: (context, habitsSnapshot) {
          if (habitsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final habits = habitsSnapshot.data ?? [];
          return StreamBuilder<List<CompletionEntry>>(
            stream: firestoreService.completionsStream(user.uid),
            builder: (context, completionSnapshot) {
              if (completionSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final completions = completionSnapshot.data ?? [];
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            child: Icon(Icons.person, size: 30),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              user.email ?? 'Unknown user',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (habits.isEmpty && completions.isEmpty)
                    const EmptyState(
                      icon: Icons.insights_outlined,
                      title: 'No stats yet',
                      subtitle: 'Create and complete habits to see your profile stats.',
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _ProfileStat(title: 'Total habits created', value: habits.length),
                            const Divider(height: 22),
                            _ProfileStat(
                              title: 'Total completions (all-time)',
                              value: completions.length,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: authService.signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.title, required this.value});

  final String title;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title)),
        Text(
          '$value',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
