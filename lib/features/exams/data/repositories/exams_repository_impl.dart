import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aula/core/database/app_database.dart';
import 'package:aula/core/database/daos/exams_dao.dart';
import 'package:aula/core/errors/failure.dart';
import 'package:aula/core/errors/result.dart';
import 'package:aula/features/exams/domain/entities/exam.dart';
import 'package:aula/features/exams/domain/repositories/exams_repository.dart';

class ExamsRepositoryImpl implements IExamsRepository {
  ExamsRepositoryImpl(this._examsDao);

  final ExamsDao _examsDao;

  @override
  Stream<List<Exam>> watchUpcomingExams() => _examsDao.watchUpcomingExams();

  @override
  Stream<List<Exam>> watchOverdueExams() => _examsDao.watchOverdueExams();

  @override
  Stream<List<Exam>> watchExamsBySubject(String subjectId) => _examsDao.watchExamsBySubject(subjectId);

  @override
  Stream<List<Exam>> watchAllActiveExams() => _examsDao.watchAllActiveExams();

  @override
  Future<Result<Exam?>> getExamById(String id) async {
    try {
      final exam = await _examsDao.getExamById(id);
      return Success(exam);
    } catch (e) {
      return Error(DatabaseFailure('Error al obtener la evaluación', e));
    }
  }

  @override
  Future<Result<void>> createExam(Exam exam) async {
    try {
      await _examsDao.insertExam(exam);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al guardar la evaluación', e));
    }
  }

  @override
  Future<Result<void>> updateExam(Exam exam) async {
    try {
      await _examsDao.updateExam(exam);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al actualizar la evaluación', e));
    }
  }

  @override
  Future<Result<void>> deleteExam(String id) async {
    try {
      await _examsDao.softDeleteExam(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al eliminar la evaluación', e));
    }
  }

  @override
  Future<Result<void>> restoreExam(String id) async {
    try {
      await _examsDao.restoreExam(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al restaurar la evaluación', e));
    }
  }

  @override
  Future<Result<List<Exam>>> findConflictingExams(Exam candidate) async {
    try {
      final conflicts = await _examsDao.findConflictingExams(candidate);
      return Success(conflicts);
    } catch (e) {
      return Error(DatabaseFailure('Error al verificar conflictos de fecha', e));
    }
  }
}

final examsRepositoryProvider = Provider<IExamsRepository>((ref) {
  final dao = ref.watch(examsDaoProvider);
  return ExamsRepositoryImpl(dao);
});

final upcomingExamsProvider = StreamProvider<List<Exam>>((ref) {
  final repo = ref.watch(examsRepositoryProvider);
  return repo.watchUpcomingExams();
});

final overdueExamsProvider = StreamProvider<List<Exam>>((ref) {
  final repo = ref.watch(examsRepositoryProvider);
  return repo.watchOverdueExams();
});

final allExamsProvider = StreamProvider<List<Exam>>((ref) {
  final repo = ref.watch(examsRepositoryProvider);
  return repo.watchAllActiveExams();
});
