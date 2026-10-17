import 'package:aula/features/grades/domain/entities/grade_entry.dart';

class GradeCalculationResult {
  const GradeCalculationResult({
    required this.simpleAverage,
    required this.weightedAverage,
    required this.totalWeight,
    required this.count,
  });

  final double simpleAverage;
  final double weightedAverage;
  final double totalWeight;
  final int count;
}

class GradeCalculator {
  GradeCalculator._();

  /// Calculates simple and weighted averages for a collection of grades.
  static GradeCalculationResult calculate(List<GradeEntry> grades) {
    if (grades.isEmpty) {
      return const GradeCalculationResult(
        simpleAverage: 0.0,
        weightedAverage: 0.0,
        totalWeight: 0.0,
        count: 0,
      );
    }

    double sum = 0.0;
    double weightedSum = 0.0;
    double totalWeight = 0.0;

    for (final grade in grades) {
      sum += grade.value;
      weightedSum += (grade.value * grade.weight);
      totalWeight += grade.weight;
    }

    final simpleAverage = sum / grades.length;
    final weightedAverage = totalWeight > 0 ? (weightedSum / totalWeight) : 0.0;

    return GradeCalculationResult(
      simpleAverage: simpleAverage,
      weightedAverage: weightedAverage,
      totalWeight: totalWeight,
      count: grades.length,
    );
  }

  /// Calculates what grade is needed on a future evaluation to reach a [targetAverage].
  ///
  /// Equation: (currentWeightedSum + requiredGrade * nextWeight) / (currentWeight + nextWeight) = targetAverage
  /// => requiredGrade = (targetAverage * (currentWeight + nextWeight) - currentWeightedSum) / nextWeight
  static double calculateRequiredGrade({
    required double currentWeightedSum,
    required double currentTotalWeight,
    required double nextEvaluationWeight,
    required double targetAverage,
  }) {
    if (nextEvaluationWeight <= 0) return 0.0;

    final targetTotalWeight = currentTotalWeight + nextEvaluationWeight;
    final requiredGrade = (targetAverage * targetTotalWeight - currentWeightedSum) / nextEvaluationWeight;

    return requiredGrade;
  }
}
