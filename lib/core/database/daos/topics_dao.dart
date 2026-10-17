import 'package:drift/drift.dart';
import 'package:aula/core/database/app_database.dart';
import 'package:aula/core/database/mappers/database_mappers.dart';
import 'package:aula/core/database/tables/topics_table.dart';
import 'package:aula/features/topics/domain/entities/topic.dart';

part 'topics_dao.g.dart';

@DriftAccessor(tables: [TopicsTable])
class TopicsDao extends DatabaseAccessor<AppDatabase> with _$TopicsDaoMixin {
  TopicsDao(super.db);

  Stream<List<Topic>> watchTopicsBySubject(String subjectId) {
    return (select(topicsTable)
          ..where((t) => t.deletedAt.isNull() & t.subjectId.equals(subjectId))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder, mode: OrderingMode.asc)]))
        .watch()
        .map((rows) => rows.map(DatabaseMappers.toTopic).toList());
  }

  Stream<List<Topic>> watchTopicsByExam(String examId) {
    return (select(topicsTable)
          ..where((t) => t.deletedAt.isNull() & t.examId.equals(examId))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder, mode: OrderingMode.asc)]))
        .watch()
        .map((rows) => rows.map(DatabaseMappers.toTopic).toList());
  }

  Future<void> insertTopic(Topic topic) async {
    final companion = DatabaseMappers.toTopicCompanion(topic);
    await into(topicsTable).insert(companion);
  }

  Future<void> updateTopic(Topic topic) async {
    final companion = DatabaseMappers.toTopicCompanion(topic);
    await (update(topicsTable)..where((t) => t.id.equals(topic.id))).write(companion);
  }

  /// Atomic batch update for physical drag & drop reordering
  Future<void> reorderTopics(List<Topic> reordered) async {
    await transaction(() async {
      for (int i = 0; i < reordered.length; i++) {
        final item = reordered[i];
        await (update(topicsTable)..where((t) => t.id.equals(item.id))).write(
          TopicsTableCompanion(
            sortOrder: Value(i),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  Future<void> softDeleteTopic(String id) async {
    await (update(topicsTable)..where((t) => t.id.equals(id))).write(
      TopicsTableCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> restoreTopic(String id) async {
    await (update(topicsTable)..where((t) => t.id.equals(id))).write(
      TopicsTableCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
