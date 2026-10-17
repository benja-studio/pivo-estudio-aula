import 'package:aula/core/errors/result.dart';
import 'package:aula/features/subjects/domain/entities/schedule_slot.dart';
import 'package:aula/features/subjects/domain/entities/subject.dart';

abstract class ISubjectsRepository {
  Stream<List<Subject>> watchActiveSubjects();
  Future<Result<List<Subject>>> getAllActiveSubjects();
  Future<Result<Subject?>> getSubjectById(String id);
  Future<Result<void>> createSubject(Subject subject, {List<ScheduleSlot>? scheduleSlots});
  Future<Result<void>> updateSubject(Subject subject, {List<ScheduleSlot>? scheduleSlots});
  Future<Result<void>> deleteSubject(String id);
  Future<Result<void>> restoreSubject(String id);
  Future<Result<List<ScheduleSlot>>> getScheduleSlots(String subjectId);
}
