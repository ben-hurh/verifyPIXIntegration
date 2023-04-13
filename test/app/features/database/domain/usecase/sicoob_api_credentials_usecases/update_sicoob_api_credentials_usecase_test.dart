import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';
import 'package:verify/app/features/database/domain/entities/sicoob_api_credentials_entity.dart';
import 'package:verify/app/features/database/domain/errors/api_credentials_error.dart';
import 'package:verify/app/features/database/domain/repository/api_credentials_repository.dart';
import 'package:verify/app/features/database/domain/usecase/sicoob_api_credentials_usecases/update_sicoob_api_credentials_usecase.dart';

class MockApiCredentialsRepository extends Mock
    implements ApiCredentialsRepository {}

void main() {
  late UpdateSicoobApiCredentialsUseCase updateSicoobApiCredentialsUseCase;
  late ApiCredentialsRepository apiCredentialsRepository;
  late SicoobApiCredentialsEntity sicoobApiCredentialsEntity;

  setUp(() {
    apiCredentialsRepository = MockApiCredentialsRepository();
    updateSicoobApiCredentialsUseCase = UpdateSicoobApiCredentialsUseCaseImpl(
      apiCredentialsRepository,
    );
    sicoobApiCredentialsEntity = SicoobApiCredentialsEntity(
      certificateBase64String: '',
      certificatePassword: '',
      clientID: '',
      isFavorite: false,
    );
    registerFallbackValue(sicoobApiCredentialsEntity);
  });

  group('UpdateSicoobApiCredentialsUseCase: ', () {
    test('Should return success on saveSicoobApiCredentials', () async {
      when(() => apiCredentialsRepository.updateSicoobApiCredentials(
              id: any(named: 'id'),
              sicoobApiCredentialsEntity:
                  any(named: 'sicoobApiCredentialsEntity')))
          .thenAnswer((_) async => const Success(Void));

      final response = await updateSicoobApiCredentialsUseCase(
        id: 'userID',
        sicoobApiCredentialsEntity: sicoobApiCredentialsEntity,
      );

      expect(response.isSuccess(), true);

      verify(() => apiCredentialsRepository.updateSicoobApiCredentials(
            id: any(named: 'id'),
            sicoobApiCredentialsEntity:
                any(named: 'sicoobApiCredentialsEntity'),
          )).called(1);
    });

    test('Should return ErrorUpdateApiCredentials on saveSicoobApiCredentials',
        () async {
      final apiCredentialsError = ErrorUpdateApiCredentials(
        message: 'Error Update Credentials',
      );

      when(() => apiCredentialsRepository.updateSicoobApiCredentials(
              id: any(named: 'id'),
              sicoobApiCredentialsEntity:
                  any(named: 'sicoobApiCredentialsEntity')))
          .thenAnswer((_) async => Failure(apiCredentialsError));

      final response = await updateSicoobApiCredentialsUseCase(
        id: 'userID',
        sicoobApiCredentialsEntity: sicoobApiCredentialsEntity,
      );

      final result = response.exceptionOrNull();

      expect(result, isNotNull);
      expect(result!.message, equals('Error Update Credentials'));
    });
  });
}
