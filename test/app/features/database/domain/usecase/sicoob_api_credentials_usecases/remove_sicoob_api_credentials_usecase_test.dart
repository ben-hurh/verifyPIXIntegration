import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';
import 'package:verify/app/features/database/domain/entities/sicoob_api_credentials_entity.dart';
import 'package:verify/app/features/database/domain/errors/api_credentials_error.dart';
import 'package:verify/app/features/database/domain/repository/api_credentials_repository.dart';
import 'package:verify/app/features/database/domain/usecase/sicoob_api_credentials_usecases/remove_sicoob_api_credentials_usecase.dart';

class MockApiCredentialsRepository extends Mock
    implements ApiCredentialsRepository {}

void main() {
  late RemoveSicoobApiCredentialsUseCase removeSicoobApiCredentialsUseCase;
  late ApiCredentialsRepository apiCredentialsRepository;
  late SicoobApiCredentialsEntity sicoobApiCredentialsEntity;

  setUp(() {
    apiCredentialsRepository = MockApiCredentialsRepository();
    removeSicoobApiCredentialsUseCase = RemoveSicoobApiCredentialsUseCaseImpl(
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

  group('RemoveSicoobApiCredentialsUseCase: ', () {
    test('Should return success on saveSicoobApiCredentials', () async {
      when(() => apiCredentialsRepository.removeSicoobApiCredentials(
            id: any(named: 'id'),
          )).thenAnswer((_) async => const Success(Void));

      final response = await removeSicoobApiCredentialsUseCase(
        id: 'userID',
      );

      expect(response.isSuccess(), true);

      verify(() => apiCredentialsRepository.removeSicoobApiCredentials(
            id: any(named: 'id'),
          )).called(1);
    });

    test('Should return ErrorUpdateApiCredentials on saveSicoobApiCredentials',
        () async {
      final apiCredentialsError = ErrorUpdateApiCredentials(
        message: 'Error Update Credentials',
      );

      when(() => apiCredentialsRepository.removeSicoobApiCredentials(
            id: any(named: 'id'),
          )).thenAnswer((_) async => Failure(apiCredentialsError));

      final response = await removeSicoobApiCredentialsUseCase(
        id: 'userID',
      );

      final result = response.exceptionOrNull();

      expect(result, isNotNull);
      expect(result!.message, equals('Error Update Credentials'));
    });
  });
}
