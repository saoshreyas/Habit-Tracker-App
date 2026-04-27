import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/completion_entry.dart';
import '../models/habit.dart';
import '../models/habit_stats.dart';
import '../utils/date_helpers.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _habitsRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('habits');

  CollectionReference<Map<String, dynamic>> _completionsRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('completions');

  Stream<List<Habit>> habitsStream(String uid) {
    return _habitsRef(
      uid,
    ).orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Habit.fromFirestore(doc)).toList(),
    );
  }

  Stream<List<CompletionEntry>> completionsStream(String uid) {
    return _completionsRef(
      uid,
    ).orderBy('completedAt', descending: true).snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => CompletionEntry.fromFirestore(doc)).toList(),
    );
  }

  Stream<List<CompletionEntry>> completionsForHabitStream(
    String uid,
    String habitId,
  ) {
    return _completionsRef(uid)
        .where('habitId', isEqualTo: habitId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CompletionEntry.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> addHabit({
    required String uid,
    required String name,
    required String emoji,
    required int colorValue,
    required bool isDaily,
  }) async {
    await _habitsRef(uid).add({
      'name': name.trim(),
      'emoji': emoji,
      'color': colorValue,
      'isDaily': isDaily,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateHabit({
    required String uid,
    required String habitId,
    required String name,
    required String emoji,
    required int colorValue,
    required bool isDaily,
  }) async {
    await _habitsRef(uid).doc(habitId).update({
      'name': name.trim(),
      'emoji': emoji,
      'color': colorValue,
      'isDaily': isDaily,
    });
  }

  Future<void> deleteHabit({required String uid, required String habitId}) async {
    final completionQuery = await _completionsRef(uid)
        .where('habitId', isEqualTo: habitId)
        .get();

    final batch = _firestore.batch();
    for (final doc in completionQuery.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_habitsRef(uid).doc(habitId));
    await batch.commit();
  }

  Future<void> setCompletion({
    required String uid,
    required String habitId,
    required DateTime date,
    required bool completed,
  }) async {
    final dateString = toDateString(date);
    final completionId = '${dateString}_$habitId';
    final ref = _completionsRef(uid).doc(completionId);

    if (completed) {
      await ref.set({
        'habitId': habitId,
        'date': dateString,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.delete();
    }
  }

  HabitStats calculateStats(List<CompletionEntry> completions) {
    if (completions.isEmpty) {
      return const HabitStats(currentStreak: 0, longestStreak: 0, totalCompletions: 0);
    }

    final uniqueDates = completions.map((e) => e.date).toSet().toList()..sort();
    final sortedDates = uniqueDates.map(fromDateString).toList()..sort();

    var longest = 0;
    var running = 0;
    DateTime? previous;
    for (final date in sortedDates) {
      if (previous == null || date.difference(previous).inDays == 1) {
        running += 1;
      } else {
        running = 1;
      }
      if (running > longest) {
        longest = running;
      }
      previous = date;
    }

    final dateSet = sortedDates.map(toDateString).toSet();
    var current = 0;
    var cursor = DateTime.now();
    if (!dateSet.contains(toDateString(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    while (dateSet.contains(toDateString(cursor))) {
      current += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return HabitStats(
      currentStreak: current,
      longestStreak: longest,
      totalCompletions: uniqueDates.length,
    );
  }
}
