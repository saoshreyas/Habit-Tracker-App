import 'package:flutter/material.dart';

import '../models/habit.dart';

class HabitCard extends StatefulWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.completed,
    required this.streak,
    required this.onToggle,
    required this.onTap,
    required this.onEdit,
  });

  final Habit habit;
  final bool completed;
  final int streak;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      lowerBound: 0.96,
      upperBound: 1,
      value: 1,
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  @override
  void didUpdateWidget(covariant HabitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.completed != widget.completed && widget.completed) {
      _controller
        ..value = 0.96
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.completed;
    return ScaleTransition(
      scale: _scale,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: widget.habit.color.withOpacity(0.2),
                  child: Text(widget.habit.emoji, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.habit.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? Colors.black45 : null,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Streak: ${widget.streak} day${widget.streak == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: isCompleted ? widget.habit.color : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                GestureDetector(
                  onTap: widget.onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: isCompleted ? widget.habit.color : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCompleted ? widget.habit.color : Colors.black26,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 20,
                      color: isCompleted ? Colors.white : Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
