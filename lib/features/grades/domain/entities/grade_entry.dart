enum GradeKind {
  exam('exam', 'Examen / Parcial'),
  assignment('assignment', 'Trabajo Práctico'),
  concept('concept', 'Nota Conceptual'),
  participation('participation', 'Participación');

  const GradeKind(this.code, this.label);
  final String code;
  final String label;

  static GradeKind fromCode(String code) {
    return GradeKind.values.firstWhere(
      (e) => e.code == code,
      orElse: () => GradeKind.exam,
    );
  }
}

class GradeEntry {
  const GradeEntry({
    required this.id,
    required this.subjectId,
    this.examId,
    required this.title,
    required this.value,
    this.weight = 1.0,
    this.kind = GradeKind.exam,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String subjectId;
  final String? examId;
  final String title;
  final double value;
  final double weight;
  final GradeKind kind;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  GradeEntry copyWith({
    String? id,
    String? subjectId,
    String? examId,
    String? title,
    double? value,
    double? weight,
    GradeKind? kind,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return GradeEntry(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      examId: examId ?? this.examId,
      title: title ?? this.title,
      value: value ?? this.value,
      weight: weight ?? this.weight,
      kind: kind ?? this.kind,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
