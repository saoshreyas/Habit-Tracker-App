import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../services/firestore_service.dart';

class AddEditHabitScreen extends StatefulWidget {
  const AddEditHabitScreen({super.key, this.habit});

  final Habit? habit;

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _saving = false;
  bool _isDaily = true;
  String _selectedEmoji = '✅';
  Color _selectedColor = const Color(0xFF6C63FF);

  static const _emojis = ['✅', '🏃', '💧', '📚', '🧘', '🥗', '😴', '💪'];
  static const _colors = [
    Color(0xFF6C63FF),
    Color(0xFF26A69A),
    Color(0xFF42A5F5),
    Color(0xFFFF7043),
    Color(0xFFAB47BC),
    Color(0xFF66BB6A),
  ];

  @override
  void initState() {
    super.initState();
    final habit = widget.habit;
    if (habit != null) {
      _nameController.text = habit.name;
      _selectedEmoji = habit.emoji;
      _selectedColor = habit.color;
      _isDaily = habit.isDaily;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }
    setState(() => _saving = true);
    final service = context.read<FirestoreService>();

    try {
      if (widget.habit == null) {
        await service.addHabit(
          uid: uid,
          name: _nameController.text.trim(),
          emoji: _selectedEmoji,
          colorValue: _selectedColor.value,
          isDaily: _isDaily,
        );
      } else {
        await service.updateHabit(
          uid: uid,
          habitId: widget.habit!.id,
          name: _nameController.text.trim(),
          emoji: _selectedEmoji,
          colorValue: _selectedColor.value,
          isDaily: _isDaily,
        );
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final habit = widget.habit;
    if (uid == null || habit == null) {
      return;
    }
    final service = context.read<FirestoreService>();
    await service.deleteHabit(uid: uid, habitId: habit.id);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habit != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Habit' : 'Add Habit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Habit name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a habit name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name is too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              Text('Pick an emoji', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _emojis.map((emoji) {
                  final selected = emoji == _selectedEmoji;
                  return ChoiceChip(
                    selected: selected,
                    label: Text(emoji, style: const TextStyle(fontSize: 20)),
                    onSelected: (_) => setState(() => _selectedEmoji = emoji),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              Text('Accent color', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _colors.map((color) {
                  final selected = _selectedColor.value == color.value;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isDaily,
                onChanged: (value) => setState(() => _isDaily = value),
                title: const Text('Daily habit'),
                subtitle: const Text('Keep enabled for daily tracking'),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'Save Changes' : 'Create Habit'),
                ),
              ),
              if (isEditing) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _saving ? null : _delete,
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete Habit'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
