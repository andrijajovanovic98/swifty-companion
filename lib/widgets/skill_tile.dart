import 'package:flutter/material.dart';

class SkillTile extends StatelessWidget {
  final String name;
  final double level;

  const SkillTile({super.key, required this.name, required this.level});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name),
            Text('${(level * 100).toStringAsFixed(0)}%'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: level.clamp(0.0, 1.0),
          backgroundColor: Colors.grey.shade300,
          color: Colors.blueAccent,
          minHeight: 6,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
