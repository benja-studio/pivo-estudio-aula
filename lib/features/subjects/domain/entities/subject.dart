enum SubjectStatus {
  taking('taking', 'Cursando'),
  regular('regular', 'Regular'),
  passed('passed', 'Aprobada'),
  failed('failed', 'Libre'),
  retaking('retaking', 'Recursando');

  const SubjectStatus(this.code, this.label);
  final String code;
  final String label;

  static SubjectStatus fromCode(String code) {
    return SubjectStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => SubjectStatus.taking,
    );
  }
}

class Subject {
  const Subject({
    required this.id,
    required this.name,
    this.code,
    required this.colorValue,
    this.iconName = 'book',
    this.professor,
    this.classroom,
    this.credits,
    this.status = SubjectStatus.taking,
    this.period,
    this.customPassingGrade,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String name;
  final String? code;
  final int colorValue;
  final String iconName;
  final String? professor;
  final String? classroom;
  final int? credits;
  final SubjectStatus status;
  final String? period;
  final double? customPassingGrade;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Subject copyWith({
    String? id,
    String? name,
    String? code,
    int? colorValue,
    String? iconName,
    String? professor,
    String? classroom,
    int? credits,
    SubjectStatus? status,
    String? period,
    double? customPassingGrade,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
      professor: professor ?? this.professor,
      classroom: classroom ?? this.classroom,
      credits: credits ?? this.credits,
      status: status ?? this.status,
      period: period ?? this.period,
      customPassingGrade: customPassingGrade ?? this.customPassingGrade,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
