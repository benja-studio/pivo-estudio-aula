import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aula/core/database/app_database.dart';
import 'package:aula/core/database/daos/subjects_dao.dart';
import 'package:aula/core/errors/failure.dart';
import 'package:aula/core/errors/result.dart';
import 'package:aula/features/subjects/domain/entities/schedule_slot.dart';
import 'package:aula/features/subjects/domain/entities/subject.dart';
import 'package:aula/features/subjects/domain/repositories/subjects_repository.dart';

class SubjectsRepositoryImpl implements ISubjectsRepository {
  SubjectsRepositoryImpl(this._subjectsDao);

  final SubjectsDao _subjectsDao;

  @override
  Stream<List<Subject>> watchActiveSubjects() {
    return _subjectsDao.watchActiveSubjects();
  }

  @override
  Future<Result<List<Subject>>> getAllActiveSubjects() async {
    try {
      final list = await _subjectsDao.getAllActiveSubjects();
      return Success(list);
    } catch (e) {
      return Error(DatabaseFailure('Error al obtener materias', e));
    }
  }

  @override
  Future<Result<Subject?>> getSubjectById(String id) async {
    try {
      final subject = await _subjectsDao.getSubjectById(id);
      return Success(subject);
    } catch (e) {
      return Error(DatabaseFailure('Error al obtener la materia', e));
    }
  }

  @override
  Future<Result<void>> createSubject(Subject subject, {List<ScheduleSlot>? scheduleSlots}) async {
    try {
      await _subjectsDao.insertSubject(subject);
      if (scheduleSlots != null && scheduleSlots.isNotEmpty) {
        await _subjectsDao.setScheduleSlots(subject.id, scheduleSlots);
      }
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al crear la materia', e));
    }
  }

  @override
  Future<Result<void>> updateSubject(Subject subject, {List<ScheduleSlot>? scheduleSlots}) async {
    try {
      await _subjectsDao.updateSubject(subject);
      if (scheduleSlots != null) {
        await _subjectsDao.setScheduleSlots(subject.id, scheduleSlots);
      }
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al actualizar la materia', e));
    }
  }

  @override
  Future<Result<void>> deleteSubject(String id) async {
    try {
      await _subjectsDao.softDeleteSubject(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al eliminar la materia', e));
    }
  }

  @override
  Future<Result<void>> restoreSubject(String id) async {
    try {
      await _subjectsDao.restoreSubject(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al restaurar la materia', e));
    }
  }

  @override
  Future<Result<List<ScheduleSlot>>> getScheduleSlots(String subjectId) async {
    try {
      final slots = await _subjectsDao.getScheduleSlots(subjectId);
      return Success(slots);
    } catch (e) {
      return Error(DatabaseFailure('Error al obtener horarios de la materia', e));
    }
  }
}

final subjectsRepositoryProvider = Provider<ISubjectsRepository>((ref) {
  final dao = ref.watch(subjectsDaoProvider);
  return SubjectsRepositoryImpl(dao);
});

final activeSubjectsProvider = StreamProvider<List<Subject>>((ref) {
  final repo = ref.watch(subjectsRepositoryProvider);
  return repo.watchActiveSubjects();
});
