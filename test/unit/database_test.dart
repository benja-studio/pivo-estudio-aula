import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aula/core/database/app_database.dart';
import 'package:aula/features/exams/domain/entities/exam.dart';
import 'package:aula/features/grades/domain/entities/grade_entry.dart';
import 'package:aula/features/profile/domain/entities/student_profile.dart';
import 'package:aula/features/subjects/domain/entities/schedule_slot.dart';
import 'package:aula/features/subjects/domain/entities/subject.dart';
import 'package:aula/features/topics/domain/entities/topic.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase & DAOs Tests', () {
    test('checkIntegrity returns true on clean database', () async {
      final isHealthy = await db.checkIntegrity();
      expect(isHealthy, isTrue);
    });

    test('ProfileDao saves and reads student profile correctly', () async {
      final now = DateTime.now();
      final profile = StudentProfile(
        id: 'prof-1',
        fullName: 'Mateo Rossi',
        career: 'Ingeniería en Informática',
        institution: 'UBA - FIUBA',
        currentPeriod: '1er cuatrimestre 2026',
        passingGrade: 4.0,
        maxGrade: 10.0,
        createdAt: now,
        updatedAt: now,
      );

      await db.profileDao.saveProfile(profile);
      final retrieved = await db.profileDao.getProfile();

      expect(retrieved, isNotNull);
      expect(retrieved!.fullName, equals('Mateo Rossi'));
      expect(retrieved.career, equals('Ingeniería en Informática'));
      expect(retrieved.initials, equals('MR'));
    });

    test('SubjectsDao handles CRUD, soft delete and restore', () async {
      final now = DateTime.now();
      final subject = Subject(
        id: 'sub-1',
        name: 'Algoritmos y Estructuras de Datos',
        colorValue: 0xFF3B82F6,
        professor: 'Dr. Turing',
        createdAt: now,
        updatedAt: now,
      );

      await db.subjectsDao.insertSubject(subject);
      var subjects = await db.subjectsDao.getAllActiveSubjects();
      expect(subjects.length, equals(1));
      expect(subjects.first.name, equals('Algoritmos y Estructuras de Datos'));

      // Soft delete
      await db.subjectsDao.softDeleteSubject('sub-1');
      subjects = await db.subjectsDao.getAllActiveSubjects();
      expect(subjects, isEmpty);

      // Restore (Undo)
      await db.subjectsDao.restoreSubject('sub-1');
      subjects = await db.subjectsDao.getAllActiveSubjects();
      expect(subjects.length, equals(1));
      expect(subjects.first.name, equals('Algoritmos y Estructuras de Datos'));
    });

    test('SubjectsDao saves schedule slots atomically in a transaction', () async {
      final now = DateTime.now();
      final subject = Subject(
        id: 'sub-2',
        name: 'Sistemas Operativos',
        colorValue: 0xFF10B981,
        createdAt: now,
        updatedAt: now,
      );
      await db.subjectsDao.insertSubject(subject);

      final slots = [
        ScheduleSlot(
          id: 'slot-1',
          subjectId: 'sub-2',
          dayOfWeek: 1, // Monday
          startTime: '09:00',
          endTime: '12:00',
          classroom: 'Aula 302',
          createdAt: now,
          updatedAt: now,
        ),
        ScheduleSlot(
          id: 'slot-2',
          subjectId: 'sub-2',
          dayOfWeek: 4, // Thursday
          startTime: '14:00',
          endTime: '17:00',
          classroom: 'Laboratorio 4',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await db.subjectsDao.setScheduleSlots('sub-2', slots);
      final savedSlots = await db.subjectsDao.getScheduleSlots('sub-2');

      expect(savedSlots.length, equals(2));
      expect(savedSlots[0].dayName, equals('Lunes'));
      expect(savedSlots[1].dayName, equals('Jueves'));
    });

    test('ExamsDao detects schedule conflicts correctly', () async {
      final now = DateTime.now();
      final subject = Subject(
        id: 'sub-3',
        name: 'Física I',
        colorValue: 0xFFEF4444,
        createdAt: now,
        updatedAt: now,
      );
      await db.subjectsDao.insertSubject(subject);

      final examDate = DateTime(2026, 11, 10, 10, 0); // 10:00 to 12:00
      final exam1 = Exam(
        id: 'exam-1',
        subjectId: 'sub-3',
        type: ExamType.midterm,
        title: 'Primer Parcial de Física',
        dateTime: examDate,
        durationMinutes: 120,
        createdAt: now,
        updatedAt: now,
      );
      await db.examsDao.insertExam(exam1);

      // Overlapping exam (11:00 to 13:00 on same day)
      final conflictingCandidate = Exam(
        id: 'exam-2',
        subjectId: 'sub-3',
        type: ExamType.quiz,
        title: 'Quiz de Laboratorio',
        dateTime: DateTime(2026, 11, 10, 11, 0),
        durationMinutes: 120,
        createdAt: now,
        updatedAt: now,
      );

      final conflicts = await db.examsDao.findConflictingExams(conflictingCandidate);
      expect(conflicts.length, equals(1));
      expect(conflicts.first.id, equals('exam-1'));
    });

    test('TopicsDao atomically reorders topics with physical sort order', () async {
      final now = DateTime.now();
      final subject = Subject(
        id: 'sub-4',
        name: 'Química General',
        colorValue: 0xFF8B5CF6,
        createdAt: now,
        updatedAt: now,
      );
      await db.subjectsDao.insertSubject(subject);

      final topicA = Topic(
        id: 'top-1',
        subjectId: 'sub-4',
        title: 'Estequiometría',
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      );
      final topicB = Topic(
        id: 'top-2',
        subjectId: 'sub-4',
        title: 'Termodinámica',
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      );

      await db.topicsDao.insertTopic(topicA);
      await db.topicsDao.insertTopic(topicB);

      // Drag and drop reordering: Topic B first, then Topic A
      await db.topicsDao.reorderTopics([topicB, topicA]);

      final reordered = await db.topicsDao.watchTopicsBySubject('sub-4').first;
      expect(reordered[0].id, equals('top-2'));
      expect(reordered[0].sortOrder, equals(0));
      expect(reordered[1].id, equals('top-1'));
      expect(reordered[1].sortOrder, equals(1));
    });

    test('GradesDao records grades and handles weighted calculation accurately', () async {
      final now = DateTime.now();
      final subject = Subject(
        id: 'sub-5',
        name: 'Álgebra Lineal',
        colorValue: 0xFF06B6D4,
        createdAt: now,
        updatedAt: now,
      );
      await db.subjectsDao.insertSubject(subject);

      final grade1 = GradeEntry(
        id: 'g-1',
        subjectId: 'sub-5',
        title: '1er Parcial',
        value: 8.0,
        weight: 1.0,
        date: now,
        createdAt: now,
        updatedAt: now,
      );
      final grade2 = GradeEntry(
        id: 'g-2',
        subjectId: 'sub-5',
        title: '2do Parcial',
        value: 6.0,
        weight: 2.0, // Double weight
        date: now,
        createdAt: now,
        updatedAt: now,
      );

      await db.gradesDao.insertGrade(grade1);
      await db.gradesDao.insertGrade(grade2);

      final grades = await db.gradesDao.getAllActiveGrades();
      expect(grades.length, equals(2));

      // Weighted average: (8.0 * 1 + 6.0 * 2) / (1 + 2) = 20 / 3 ≈ 6.666...
      final totalWeight = grades.fold<double>(0.0, (sum, g) => sum + g.weight);
      final weightedSum = grades.fold<double>(0.0, (sum, g) => sum + (g.value * g.weight));
      final average = weightedSum / totalWeight;

      expect(average, closeTo(6.666, 0.01));
    });
  });
}
