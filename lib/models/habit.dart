import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorValue,
    required this.createdAt,
    this.isDaily = true,
  });

  final String id;
  final String name;
  final String emoji;
  final int colorValue;
  final DateTime createdAt;
  final bool isDaily;

  Color get color => Color(colorValue);

  factory Habit.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAtTimestamp = data['createdAt'] as Timestamp?;
    return Habit(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      emoji: (data['emoji'] as String?) ?? '✅',
      colorValue: (data['color'] as int?) ?? Colors.teal.value,
      createdAt: createdAtTimestamp?.toDate() ?? DateTime.now(),
      isDaily: (data['isDaily'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'emoji': emoji,
      'color': colorValue,
      'createdAt': Timestamp.fromDate(createdAt),
      'isDaily': isDaily,
    };
  }
}
