import 'package:aula/core/errors/result.dart';
import 'package:aula/features/grades/domain/entities/grade_entry.dart';

abstract class IGradesRepository {
  Stream<List<GradeEntry>> watchGradesBySubject(String subjectId);
  Stream<List<GradeEntry>> watchAllActiveGrades();
  Future<Result<List<GradeEntry>>> getAllActiveGrades();
  Future<Result<GradeEntry?> > getGradeByExamId(String examId);
  Future<Result<void>> createGrade(GradeEntry grade);
  Future<Result<void>> updateGrade(GradeEntry grade);
  Future<Result<void>> deleteGrade(String id);
  Future<Result<void>> restoreGrade(String id);
}
