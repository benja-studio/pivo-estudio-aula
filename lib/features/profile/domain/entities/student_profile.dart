class StudentProfile {
  const StudentProfile({
    required this.id,
    required this.fullName,
    required this.career,
    required this.institution,
    this.academicLevel,
    this.studentId,
    this.email,
    this.currentPeriod,
    this.avatarPath,
    this.passingGrade = 4.0,
    this.maxGrade = 10.0,
    this.gradeScaleType = 'numeric10',
    this.notificationsEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String fullName;
  final String career;
  final String institution;
  final String? academicLevel;
  final String? studentId;
  final String? email;
  final String? currentPeriod;
  final String? avatarPath;
  final double passingGrade;
  final double maxGrade;
  final String gradeScaleType;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'A';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  StudentProfile copyWith({
    String? id,
    String? fullName,
    String? career,
    String? institution,
    String? academicLevel,
    String? studentId,
    String? email,
    String? currentPeriod,
    String? avatarPath,
    double? passingGrade,
    double? maxGrade,
    String? gradeScaleType,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      career: career ?? this.career,
      institution: institution ?? this.institution,
      academicLevel: academicLevel ?? this.academicLevel,
      studentId: studentId ?? this.studentId,
      email: email ?? this.email,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      avatarPath: avatarPath ?? this.avatarPath,
      passingGrade: passingGrade ?? this.passingGrade,
      maxGrade: maxGrade ?? this.maxGrade,
      gradeScaleType: gradeScaleType ?? this.gradeScaleType,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
