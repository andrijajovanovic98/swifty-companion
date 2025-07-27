import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SkillRadarChart extends StatelessWidget {
  final List<String> skillNames;
  final List<double> skillValues;

  const SkillRadarChart({
    super.key,
    required this.skillNames,
    required this.skillValues,
  });

  @override
  Widget build(BuildContext context) {
    final names = [...skillNames];
    final values = [...skillValues];

    while (names.length < 3) {
      names.add('');
      values.add(0.0);
    }

    final processedSkillNames = names.map((name) {
      return name.replaceAll(' & ', ' &\n').replaceAll(' ', '\n');
    }).toList();

    return SizedBox(
      height: 300,
      child: RadarChart(
        RadarChartData(
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          radarShape: RadarShape.circle,
          titleTextStyle: const TextStyle(fontSize: 9),
          tickCount: 5,
          ticksTextStyle: const TextStyle(fontSize: 7, color: Colors.grey),
          getTitle: (index, _) {
            final name = processedSkillNames[index];
            final level = (values[index] / 5).toStringAsFixed(2);
            return RadarChartTitle(
              text: name.isEmpty ? '' : '$name\n$level',
              angle: 0,
            );
          },
          dataSets: [
            RadarDataSet(
              fillColor: Colors.cyan.withOpacity(0.4),
              borderColor: Colors.cyan,
              entryRadius: 2,
              dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
