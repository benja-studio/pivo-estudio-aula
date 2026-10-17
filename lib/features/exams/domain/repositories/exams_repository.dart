import 'package:aula/core/errors/result.dart';
import 'package:aula/features/exams/domain/entities/exam.dart';

abstract class IExamsRepository {
  Stream<List<Exam>> watchUpcomingExams();
  Stream<List<Exam>> watchOverdueExams();
  Stream<List<Exam>> watchExamsBySubject(String subjectId);
  Stream<List<Exam>> watchAllActiveExams();
  Future<Result<Exam?>> getExamById(String id);
  Future<Result<void>> createExam(Exam exam);
  Future<Result<void>> updateExam(Exam exam);
  Future<Result<void>> deleteExam(String id);
  Future<Result<void>> restoreExam(String id);
  Future<Result<List<Exam>>> findConflictingExams(Exam candidate);
}
