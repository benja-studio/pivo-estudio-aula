import 'package:aula/core/errors/result.dart';
import 'package:aula/features/topics/domain/entities/topic.dart';

abstract class ITopicsRepository {
  Stream<List<Topic>> watchTopicsBySubject(String subjectId);
  Stream<List<Topic>> watchTopicsByExam(String examId);
  Future<Result<void>> createTopic(Topic topic);
  Future<Result<void>> updateTopic(Topic topic);
  Future<Result<void>> reorderTopics(List<Topic> reordered);
  Future<Result<void>> deleteTopic(String id);
  Future<Result<void>> restoreTopic(String id);
}
