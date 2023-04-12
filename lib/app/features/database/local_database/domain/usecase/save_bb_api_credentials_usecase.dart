import 'package:result_dart/result_dart.dart';
import 'package:verify/app/features/database/local_database/domain/errors/api_credentials_error.dart';
import 'package:verify/app/features/database/local_database/domain/repository/local_database_repository.dart';

abstract class SaveBBApiCredentialsUseCase {
  Future<Result<void, ApiCredentialsError>> call();
}

class SaveBBApiCredentialsUseCaseImpl implements SaveBBApiCredentialsUseCase {
  final LocalDataBaseRepository _localDataBaseRepository;
  SaveBBApiCredentialsUseCaseImpl(this._localDataBaseRepository);

  @override
  Future<Result<void, ApiCredentialsError>> call() async {
    return await _localDataBaseRepository.saveBBApiCredentials();
  }
}
