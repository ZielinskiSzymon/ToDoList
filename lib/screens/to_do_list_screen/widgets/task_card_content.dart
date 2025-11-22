import 'package:flutter/material.dart';

class TaskCardContent extends StatelessWidget {
  final String title;
  final String? description;
  final String deadline;
  final bool isCompleted; // Dodana właściwość

  const TaskCardContent({
    super.key,
    required this.title,
    this.description,
    required this.deadline,
    this.isCompleted = false, // Domyślnie false
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  // Przekreślenie tytułu
                  decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                  color: isCompleted ? Colors.grey : null,
                ),
              ),
              if (description != null && description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    // Przekreślenie opisu
                    decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 12),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              "Termin:",
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              deadline,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}