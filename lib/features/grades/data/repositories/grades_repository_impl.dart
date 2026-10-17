import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aula/core/database/app_database.dart';
import 'package:aula/core/database/daos/grades_dao.dart';
import 'package:aula/core/errors/failure.dart';
import 'package:aula/core/errors/result.dart';
import 'package:aula/features/grades/domain/entities/grade_entry.dart';
import 'package:aula/features/grades/domain/repositories/grades_repository.dart';

class GradesRepositoryImpl implements IGradesRepository {
  GradesRepositoryImpl(this._gradesDao);

  final GradesDao _gradesDao;

  @override
  Stream<List<GradeEntry>> watchGradesBySubject(String subjectId) => _gradesDao.watchGradesBySubject(subjectId);

  @override
  Stream<List<GradeEntry>> watchAllActiveGrades() => _gradesDao.watchAllActiveGrades();

  @override
  Future<Result<List<GradeEntry>>> getAllActiveGrades() async {
    try {
      final list = await _gradesDao.getAllActiveGrades();
      return Success(list);
    } catch (e) {
      return Error(DatabaseFailure('Error al obtener notas', e));
    }
  }

  @override
  Future<Result<GradeEntry?>> getGradeByExamId(String examId) async {
    try {
      final grade = await _gradesDao.getGradeByExamId(examId);
      return Success(grade);
    } catch (e) {
      return Error(DatabaseFailure('Error al obtener nota de examen', e));
    }
  }

  @override
  Future<Result<void>> createGrade(GradeEntry grade) async {
    try {
      await _gradesDao.insertGrade(grade);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al registrar la nota', e));
    }
  }

  @override
  Future<Result<void>> updateGrade(GradeEntry grade) async {
    try {
      await _gradesDao.updateGrade(grade);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al actualizar la nota', e));
    }
  }

  @override
  Future<Result<void>> deleteGrade(String id) async {
    try {
      await _gradesDao.softDeleteGrade(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al eliminar la nota', e));
    }
  }

  @override
  Future<Result<void>> restoreGrade(String id) async {
    try {
      await _gradesDao.restoreGrade(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al restaurar la nota', e));
    }
  }
}

final gradesRepositoryProvider = Provider<IGradesRepository>((ref) {
  final dao = ref.watch(gradesDaoProvider);
  return GradesRepositoryImpl(dao);
});

final allGradesProvider = StreamProvider<List<GradeEntry>>((ref) {
  final repo = ref.watch(gradesRepositoryProvider);
  return repo.watchAllActiveGrades();
});
