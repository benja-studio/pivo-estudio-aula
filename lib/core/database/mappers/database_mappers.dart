import 'package:drift/drift.dart';
import 'package:aula/core/database/app_database.dart';
import 'package:aula/features/exams/domain/entities/exam.dart';
import 'package:aula/features/grades/domain/entities/grade_entry.dart';
import 'package:aula/features/profile/domain/entities/student_profile.dart';
import 'package:aula/features/subjects/domain/entities/schedule_slot.dart';
import 'package:aula/features/subjects/domain/entities/subject.dart';
import 'package:aula/features/topics/domain/entities/topic.dart';

class DatabaseMappers {
  DatabaseMappers._();

  // Student Profile
  static StudentProfile toStudentProfile(StudentProfileRow row) {
    return StudentProfile(
      id: row.id,
      fullName: row.fullName,
      career: row.career,
      institution: row.institution,
      academicLevel: row.academicLevel,
      studentId: row.studentId,
      email: row.email,
      currentPeriod: row.currentPeriod,
      avatarPath: row.avatarPath,
      passingGrade: row.passingGrade,
      maxGrade: row.maxGrade,
      gradeScaleType: row.gradeScaleType,
      notificationsEnabled: row.notificationsEnabled,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static StudentProfilesTableCompanion toStudentProfileCompanion(StudentProfile entity) {
    return StudentProfilesTableCompanion(
      id: Value(entity.id),
      fullName: Value(entity.fullName),
      career: Value(entity.career),
      institution: Value(entity.institution),
      academicLevel: Value(entity.academicLevel),
      studentId: Value(entity.studentId),
      email: Value(entity.email),
      currentPeriod: Value(entity.currentPeriod),
      avatarPath: Value(entity.avatarPath),
      passingGrade: Value(entity.passingGrade),
      maxGrade: Value(entity.maxGrade),
      gradeScaleType: Value(entity.gradeScaleType),
      notificationsEnabled: Value(entity.notificationsEnabled),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  // Subject
  static Subject toSubject(SubjectRow row) {
    return Subject(
      id: row.id,
      name: row.name,
      code: row.code,
      colorValue: row.colorValue,
      iconName: row.iconName,
      professor: row.professor,
      classroom: row.classroom,
      credits: row.credits,
      status: SubjectStatus.fromCode(row.status),
      period: row.period,
      customPassingGrade: row.customPassingGrade,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  static SubjectsTableCompanion toSubjectCompanion(Subject entity) {
    return SubjectsTableCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      code: Value(entity.code),
      colorValue: Value(entity.colorValue),
      iconName: Value(entity.iconName),
      professor: Value(entity.professor),
      classroom: Value(entity.classroom),
      credits: Value(entity.credits),
      status: Value(entity.status.code),
      period: Value(entity.period),
      customPassingGrade: Value(entity.customPassingGrade),
      notes: Value(entity.notes),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      deletedAt: Value(entity.deletedAt),
    );
  }

  // ScheduleSlot
  static ScheduleSlot toScheduleSlot(ScheduleSlotRow row) {
    return ScheduleSlot(
      id: row.id,
      subjectId: row.subjectId,
      dayOfWeek: row.dayOfWeek,
      startTime: row.startTime,
      endTime: row.endTime,
      classroom: row.classroom,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static ScheduleSlotsTableCompanion toScheduleSlotCompanion(ScheduleSlot entity) {
    return ScheduleSlotsTableCompanion(
      id: Value(entity.id),
      subjectId: Value(entity.subjectId),
      dayOfWeek: Value(entity.dayOfWeek),
      startTime: Value(entity.startTime),
      endTime: Value(entity.endTime),
      classroom: Value(entity.classroom),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  // Exam
  static Exam toExam(ExamRow row) {
    return Exam(
      id: row.id,
      subjectId: row.subjectId,
      type: ExamType.fromCode(row.type),
      title: row.title,
      dateTime: row.examDate,
      durationMinutes: row.durationMinutes,
      classroom: row.classroom,
      notes: row.notes,
      status: ExamStatus.fromCode(row.status),
      retakeOfExamId: row.retakeOfExamId,
      retakeRule: row.retakeRule,
      reminderEnabled: row.reminderEnabled,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  static ExamsTableCompanion toExamCompanion(Exam entity) {
    return ExamsTableCompanion(
      id: Value(entity.id),
      subjectId: Value(entity.subjectId),
      type: Value(entity.type.code),
      title: Value(entity.title),
      examDate: Value(entity.dateTime),
      durationMinutes: Value(entity.durationMinutes),
      classroom: Value(entity.classroom),
      notes: Value(entity.notes),
      status: Value(entity.status.code),
      retakeOfExamId: Value(entity.retakeOfExamId),
      retakeRule: Value(entity.retakeRule),
      reminderEnabled: Value(entity.reminderEnabled),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      deletedAt: Value(entity.deletedAt),
    );
  }

  // Topic
  static Topic toTopic(TopicRow row) {
    return Topic(
      id: row.id,
      subjectId: row.subjectId,
      examId: row.examId,
      title: row.title,
      notes: row.notes,
      status: TopicStatus.fromCode(row.status),
      priority: TopicPriority.fromCode(row.priority),
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  static TopicsTableCompanion toTopicCompanion(Topic entity) {
    return TopicsTableCompanion(
      id: Value(entity.id),
      subjectId: Value(entity.subjectId),
      examId: Value(entity.examId),
      title: Value(entity.title),
      notes: Value(entity.notes),
      status: Value(entity.status.code),
      priority: Value(entity.priority.code),
      sortOrder: Value(entity.sortOrder),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      deletedAt: Value(entity.deletedAt),
    );
  }

  // GradeEntry
  static GradeEntry toGradeEntry(GradeRow row) {
    return GradeEntry(
      id: row.id,
      subjectId: row.subjectId,
      examId: row.examId,
      title: row.title,
      value: row.value,
      weight: row.weight,
      kind: GradeKind.fromCode(row.kind),
      date: row.date,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  static GradesTableCompanion toGradeEntryCompanion(GradeEntry entity) {
    return GradesTableCompanion(
      id: Value(entity.id),
      subjectId: Value(entity.subjectId),
      examId: Value(entity.examId),
      title: Value(entity.title),
      value: Value(entity.value),
      weight: Value(entity.weight),
      kind: Value(entity.kind.code),
      date: Value(entity.date),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      deletedAt: Value(entity.deletedAt),
    );
  }
}
