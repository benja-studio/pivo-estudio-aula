class ScheduleSlot {
  const ScheduleSlot({
    required this.id,
    required this.subjectId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.classroom,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String subjectId;
  final int dayOfWeek; // 1 = Lunes, ..., 7 = Domingo
  final String startTime; // "HH:mm"
  final String endTime; // "HH:mm"
  final String? classroom;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get dayName {
    return switch (dayOfWeek) {
      1 => 'Lunes',
      2 => 'Martes',
      3 => 'Miércoles',
      4 => 'Jueves',
      5 => 'Viernes',
      6 => 'Sábado',
      7 => 'Domingo',
      _ => '',
    };
  }

  ScheduleSlot copyWith({
    String? id,
    String? subjectId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? classroom,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleSlot(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      classroom: classroom ?? this.classroom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
