import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aula/core/database/app_database.dart';
import 'package:aula/core/database/daos/profile_dao.dart';
import 'package:aula/core/errors/failure.dart';
import 'package:aula/core/errors/result.dart';
import 'package:aula/features/profile/domain/entities/student_profile.dart';
import 'package:aula/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  ProfileRepositoryImpl(this._profileDao);

  final ProfileDao _profileDao;

  @override
  Future<Result<StudentProfile?>> getProfile() async {
    try {
      final profile = await _profileDao.getProfile();
      return Success(profile);
    } catch (e) {
      return Error(DatabaseFailure('Error al obtener el perfil del estudiante', e));
    }
  }

  @override
  Stream<StudentProfile?> watchProfile() {
    return _profileDao.watchProfile();
  }

  @override
  Future<Result<void>> saveProfile(StudentProfile profile) async {
    try {
      await _profileDao.saveProfile(profile);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al guardar el perfil del estudiante', e));
    }
  }

  @override
  Future<Result<void>> deleteProfile() async {
    try {
      await _profileDao.deleteAll();
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Error al eliminar el perfil', e));
    }
  }
}

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  final dao = ref.watch(profileDaoProvider);
  return ProfileRepositoryImpl(dao);
});

final currentProfileProvider = StreamProvider<StudentProfile?>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.watchProfile();
});

final profileStreamProvider = currentProfileProvider;
