import 'package:flutter/material.dart';

class ProjectTile extends StatelessWidget {
  final String name;
  final int? finalMark;
  final String status;
  final bool? validated;


  const ProjectTile({
    super.key,
    required this.name,
    required this.status,
    this.finalMark,
    this.validated,

  });

  @override
  Widget build(BuildContext context) {
    late final String statusText;
    late final Color statusColor;

final isExam = name.toLowerCase().contains('exam');

if (validated == true && finalMark != null) {
  statusText = '✔️ $finalMark';
  statusColor = Colors.green;
} else if (validated == false && finalMark != null) {
  statusText = isExam ? '✗ $finalMark' : '✗ $finalMark';
  statusColor = Colors.red;
} else if (status == 'finished') {
  statusText = isExam ? '🧪 No mark yet' : 'unknown';
  statusColor = isExam ? Colors.blueGrey : Colors.red;
} else {
  statusText = isExam ? '🧪 Exam pending' : '⏳ IN PROGRESS';
  statusColor = isExam ? Colors.blueGrey : Colors.orange;
}

    return ListTile(
      title: Text(name),
      trailing: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
