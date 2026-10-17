import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/features/grades/domain/entities/grade_entry.dart';
import 'package:aula/features/grades/domain/services/grade_calculator.dart';
import 'package:aula/features/subjects/domain/entities/subject.dart';

class SubjectAverageData {
  const SubjectAverageData({
    required this.subject,
    required this.average,
    required this.count,
  });

  final Subject subject;
  final double average;
  final int count;
}

class GradesBySubjectBarChart extends StatelessWidget {
  const GradesBySubjectBarChart({
    super.key,
    required this.subjects,
    required this.grades,
  });

  final List<Subject> subjects;
  final List<GradeEntry> grades;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final subjectDataList = <SubjectAverageData>[];

    for (final s in subjects) {
      final subjectGrades = grades.where((g) => g.subjectId == s.id).toList();
      if (subjectGrades.isNotEmpty) {
        final calc = GradeCalculator.calculate(subjectGrades);
        subjectDataList.add(SubjectAverageData(
          subject: s,
          average: calc.weightedAverage,
          count: calc.count,
        ));
      }
    }

    if (subjectDataList.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: ShapeDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: AppRadius.continuousShape(AppRadius.lg),
        ),
        child: Text(
          'No hay materias con notas cargadas para comparar.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
          ),
        ),
      );
    }

    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < subjectDataList.length; i++) {
      final item = subjectDataList[i];
      final color = Color(item.subject.colorValue);

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: item.average,
              color: color,
              width: 18,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
      decoration: ShapeDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: AppRadius.continuousShape(
          AppRadius.lg,
          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.8),
        ),
      ),
      child: BarChart(
        BarChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) => FlLine(
              color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
              strokeWidth: 0.8,
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 2,
                getTitlesWidget: (val, meta) => Text(
                  val.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx >= 0 && idx < subjectDataList.length) {
                    final sub = subjectDataList[idx].subject;
                    final shortName = sub.name.length > 5 ? sub.name.substring(0, 4) : sub.name;
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        shortName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: 10.5,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final item = subjectDataList[group.x.toInt()];
                return BarTooltipItem(
                  '${item.subject.name}\nPromedio: ${item.average.toStringAsFixed(1)}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                );
              },
            ),
          ),
          barGroups: barGroups,
        ),
      ),
    );
  }
}
