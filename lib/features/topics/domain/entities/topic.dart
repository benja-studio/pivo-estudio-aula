enum TopicStatus {
  notStarted('notStarted', 'Sin empezar'),
  studying('studying', 'Estudiando'),
  reviewed('reviewed', 'Repasado'),
  mastered('mastered', 'Dominado');

  const TopicStatus(this.code, this.label);
  final String code;
  final String label;

  static TopicStatus fromCode(String code) {
    return TopicStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => TopicStatus.notStarted,
    );
  }

  double get progressValue => switch (this) {
        TopicStatus.notStarted => 0.0,
        TopicStatus.studying => 0.35,
        TopicStatus.reviewed => 0.70,
        TopicStatus.mastered => 1.0,
      };
}

enum TopicPriority {
  low('low', 'Baja'),
  medium('medium', 'Media'),
  high('high', 'Alta');

  const TopicPriority(this.code, this.label);
  final String code;
  final String label;

  static TopicPriority fromCode(String code) {
    return TopicPriority.values.firstWhere(
      (e) => e.code == code,
      orElse: () => TopicPriority.medium,
    );
  }
}

class Topic {
  const Topic({
    required this.id,
    required this.subjectId,
    this.examId,
    required this.title,
    this.notes,
    this.status = TopicStatus.notStarted,
    this.priority = TopicPriority.medium,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String subjectId;
  final String? examId;
  final String title;
  final String? notes;
  final TopicStatus status;
  final TopicPriority priority;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Topic copyWith({
    String? id,
    String? subjectId,
    String? examId,
    String? title,
    String? notes,
    TopicStatus? status,
    TopicPriority? priority,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Topic(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      examId: examId ?? this.examId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
