import 'package:aula/core/errors/result.dart';
import 'package:aula/features/profile/domain/entities/student_profile.dart';

abstract class IProfileRepository {
  Future<Result<StudentProfile?>> getProfile();
  Stream<StudentProfile?> watchProfile();
  Future<Result<void>> saveProfile(StudentProfile profile);
  Future<Result<void>> deleteProfile();
}
