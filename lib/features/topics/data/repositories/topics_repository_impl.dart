import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aula/core/database/app_database.dart';
import 'package:aula/core/database/daos/topics_dao.dart';
import 'package:aula/core/errors/failure.dart';
import 'package:aula/core/errors/result.dart';
import 'package:aula/features/topics/domain/entities/topic.dart';
import 'package:aula/features/topics/domain/repositories/topics_repository.dart';

class TopicsRepositoryImpl implements ITopicsRepository {
  TopicsRepositoryImpl(this._topicsDao);

  final TopicsDao _topicsDao;

  @override
  Stream<List<Topic>> watchTopicsBySubject(String subjectId) => _topicsDao.watchTopicsBySubject(subjectId);

  @override
  Stream<List<Topic>> watchTopicsByExam(String examId) => _topicsDao.watchTopicsByExam(examId);

  @override
  Future<Result<void>> createTopic(Topic topic) async {
    try {
      await _topicsDao.insertTopic(topic);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al crear el tema', e));
    }
  }

  @override
  Future<Result<void>> updateTopic(Topic topic) async {
    try {
      await _topicsDao.updateTopic(topic);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al actualizar el tema', e));
    }
  }

  @override
  Future<Result<void>> reorderTopics(List<Topic> reordered) async {
    try {
      await _topicsDao.reorderTopics(reordered);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al reordenar temas', e));
    }
  }

  @override
  Future<Result<void>> deleteTopic(String id) async {
    try {
      await _topicsDao.softDeleteTopic(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al eliminar el tema', e));
    }
  }

  @override
  Future<Result<void>> restoreTopic(String id) async {
    try {
      await _topicsDao.restoreTopic(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al restaurar el tema', e));
    }
  }
}

final topicsRepositoryProvider = Provider<ITopicsRepository>((ref) {
  final dao = ref.watch(topicsDaoProvider);
  return TopicsRepositoryImpl(dao);
});

final topicsBySubjectProvider = StreamProvider.family<List<Topic>, String>((ref, subjectId) {
  final repo = ref.watch(topicsRepositoryProvider);
  return repo.watchTopicsBySubject(subjectId);
});

final topicsByExamProvider = StreamProvider.family<List<Topic>, String>((ref, examId) {
  final repo = ref.watch(topicsRepositoryProvider);
  return repo.watchTopicsByExam(examId);
});
