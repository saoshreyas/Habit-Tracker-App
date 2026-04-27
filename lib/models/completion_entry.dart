import 'package:cloud_firestore/cloud_firestore.dart';

class CompletionEntry {
  const CompletionEntry({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completedAt,
  });

  final String id;
  final String habitId;
  final String date;
  final DateTime completedAt;

  factory CompletionEntry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final completedAtTimestamp = data['completedAt'] as Timestamp?;
    return CompletionEntry(
      id: doc.id,
      habitId: (data['habitId'] as String?) ?? '',
      date: (data['date'] as String?) ?? '',
      completedAt: completedAtTimestamp?.toDate() ?? DateTime.now(),
    );
  }
}
