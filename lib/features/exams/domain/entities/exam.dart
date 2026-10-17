enum ExamType {
  midterm('midterm', 'Parcial'),
  retake('retake', 'Recuperatorio'),
  finalExam('finalExam', 'Final'),
  assignment('assignment', 'Trabajo Práctico'),
  quiz('quiz', 'Quiz / Control'),
  oral('oral', 'Examen Oral');

  const ExamType(this.code, this.label);
  final String code;
  final String label;

  static ExamType fromCode(String code) {
    return ExamType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => ExamType.midterm,
    );
  }
}

enum ExamStatus {
  pending('pending', 'Pendiente'),
  taken('taken', 'Rendido'),
  passed('passed', 'Aprobado'),
  failed('failed', 'Desaprobado'),
  absent('absent', 'Ausente');

  const ExamStatus(this.code, this.label);
  final String code;
  final String label;

  static ExamStatus fromCode(String code) {
    return ExamStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => ExamStatus.pending,
    );
  }
}

class Exam {
  const Exam({
    required this.id,
    required this.subjectId,
    required this.type,
    required this.title,
    required this.dateTime,
    this.durationMinutes = 120,
    this.classroom,
    this.notes,
    this.status = ExamStatus.pending,
    this.retakeOfExamId,
    this.retakeRule = 'replace',
    this.reminderEnabled = true,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String subjectId;
  final ExamType type;
  final String title;
  final DateTime dateTime;
  final int durationMinutes;
  final String? classroom;
  final String? notes;
  final ExamStatus status;
  final String? retakeOfExamId;
  final String retakeRule; // 'replace' or 'average'
  final bool reminderEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  int get daysUntil {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final examDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    return examDay.difference(today).inDays;
  }

  bool get isToday => daysUntil == 0;
  bool get isUpcoming => daysUntil >= 0 && status == ExamStatus.pending;
  bool get isOverdue => daysUntil < 0 && status == ExamStatus.pending;

  DateTime get endDateTime => dateTime.add(Duration(minutes: durationMinutes));

  bool conflictsWith(Exam other) {
    if (id == other.id || isDeleted || other.isDeleted) return false;
    return dateTime.isBefore(other.endDateTime) && other.dateTime.isBefore(endDateTime);
  }

  Exam copyWith({
    String? id,
    String? subjectId,
    ExamType? type,
    String? title,
    DateTime? dateTime,
    int? durationMinutes,
    String? classroom,
    String? notes,
    ExamStatus? status,
    String? retakeOfExamId,
    String? retakeRule,
    bool? reminderEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Exam(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      type: type ?? this.type,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      classroom: classroom ?? this.classroom,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      retakeOfExamId: retakeOfExamId ?? this.retakeOfExamId,
      retakeRule: retakeRule ?? this.retakeRule,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
