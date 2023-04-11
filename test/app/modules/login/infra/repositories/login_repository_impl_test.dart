import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verify/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:verify/app/features/auth/infra/datasource/auth_datasource.dart';
import 'package:verify/app/features/auth/infra/models/user_model.dart';
import 'package:verify/app/features/auth/infra/repositories/login_repository_impl.dart';

class LoginDataSourceMock extends Mock implements AuthDataSource {}

class UserModelMock extends Mock implements UserModel {}

void main() {
  late AuthRepository authRepository;
  late AuthDataSource loginDataSource;
  late UserModelMock userModel;
  const email = 'example@example.com';
  const password = '12345678';
  setUp(() {
    loginDataSource = LoginDataSourceMock();
    authRepository = AuthRepositoryImpl(loginDataSource);
    userModel = UserModelMock();
    registerFallbackValue(userModel);
  });

  group('LoginRepository: ', () {
    test('Should call logout method from repository', () async {
      when(() => loginDataSource.logout()).thenAnswer((_) async {});

      await authRepository.logout();

      verify(() => loginDataSource.logout()).called(1);
    });

    test('Should return a UserModel when retrieving current logged in user',
        () async {
      when(() => loginDataSource.currentUser()).thenAnswer(
        (_) async => userModel,
      );

      final user = await authRepository.loggedUser();
      final result = user.getOrNull();
      expect(result, isNotNull);
    });

    test('Shoud return UserModel if login with email is successful', () async {
      when(() => loginDataSource.loginWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'))).thenAnswer((_) async => userModel);

      final response = await authRepository.loginWithEmail(
        email: email,
        password: password,
      );

      final result = response.getOrNull();
      expect(result, isNotNull);
    });
    test('Shoud return Failure if login with email is unsuccessful', () async {
      when(() => loginDataSource.loginWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'))).thenThrow(Exception());

      final response = await authRepository.loginWithEmail(
        email: email,
        password: password,
      );

      final result = response.exceptionOrNull();
      expect(result, isNotNull);
    });

    test('Shoud return UserModel if login with Google is successful', () async {
      when(() => loginDataSource.loginWithGoogle()).thenAnswer(
        (_) async => userModel,
      );
      final response = await authRepository.loginWithGoogle();

      final result = response.getOrNull();
      expect(result, isNotNull);
    });

    test('Shoud return UserModel if login with Google is unsuccessful',
        () async {
      when(() => loginDataSource.loginWithGoogle()).thenThrow(Exception());
      final response = await authRepository.loginWithGoogle();

      final result = response.exceptionOrNull();
      expect(result, isNotNull);
    });
  });
}
