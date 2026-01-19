import 'package:flutter/material.dart';

class StatusTracker extends StatelessWidget {
  final int step;
  const StatusTracker({super.key, required this.step});

  final steps = const [
    "Request Placed",
    "Volunteer Assigned",
    "On the Way",
    "Arrived",
    "Completed"
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (i) {
        return Row(
          children: [
            Icon(
              Icons.check_circle,
              color: i <= step ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(steps[i]),
          ],
        );
      }),
    );
  }
}
