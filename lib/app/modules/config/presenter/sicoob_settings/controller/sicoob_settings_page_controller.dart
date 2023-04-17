import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:pix_sicoob/pix_sicoob.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:verify/app/modules/auth/domain/usecase/get_logged_user_usecase.dart';
import 'package:verify/app/modules/config/presenter/sicoob_settings/store/sicoob_settings_store.dart';
import 'package:verify/app/modules/database/domain/entities/sicoob_api_credentials_entity.dart';
import 'package:verify/app/modules/database/domain/usecase/sicoob_api_credentials_usecases/save_sicoob_api_credentials_usecase.dart';
import 'package:verify/app/modules/database/utils/database_enums.dart';
import 'package:verify/app/shared/services/sicoob_pix_api_service/sicoob_pix_api_service.dart';

class SicoobSettingsPageController {
  final SicoobPixApiService _pixSicoobService;
  final SicoobSettingsStore _store;
  final SaveSicoobApiCredentialsUseCase _saveSicoobApiCredentialsUseCase;
  final GetLoggedUserUseCase _getLoggedUserUseCase;

  //
  String certificateString = '';
  final clientIDController = TextEditingController();
  final certificatePasswordController = TextEditingController();
  final clientIDFocus = FocusNode();
  final certificatePasswordFocus = FocusNode();
  final formKey = GlobalKey<FormState>();

  SicoobSettingsPageController(
    this._pixSicoobService,
    this._store,
    this._saveSicoobApiCredentialsUseCase,
    this._getLoggedUserUseCase,
  );
  void backToSettings() {
    clientIDFocus.unfocus();
    certificatePasswordFocus.unfocus();
    certificateString = '';
    certificatePasswordController.clear();
    clientIDController.clear();
    Modular.to.pushReplacementNamed('./');
    clearStore();
  }

  Future<void> goToSicoobDevelopersPortal() async {
    final sicoobDeveloperUrl = Uri.parse(
      'https://developers.sicoob.com.br/portal/#!/',
    );
    await launchUrl(sicoobDeveloperUrl);
  }

  void validateFields() {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      _store.setValidFields(true);
    } else {
      _store.setValidFields(false);
    }
  }

  String? validateClientID(String? input) {
    if (input != null) {
      if (input.isEmpty) {
        return 'Insira um client ID';
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  String? validateCertificatePassword(String? input) {
    if (input != null) {
      if (input.isEmpty) {
        return 'Insira um client ID';
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<void> pickCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pfx', 'cer', 'crt'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final certBase64String = PixSicoob.certFileToBase64String(
        pkcs12CertificateFile: file,
      );
      certificateString = certBase64String;
      final fileName = file.path.split('/').last;
      _store.setCertificateFileName(fileName);
    }
  }

  Future<String?> validateCredentials() async {
    _store.validatingCredentials(true);
    final response = await _pixSicoobService.validateCredentials(
      clientID: clientIDController.text,
      certificateBase64String: certificateString,
      certificatePassword: certificatePasswordController.text,
    );
    _store.validatingCredentials(false);
    return response;
  }

  Future<String?> saveCredentialsinCloud() async {
    _store.savingInCloud(true);
    final message = await _saveCredentialsinDatabase(Database.cloud);
    _store.savingInCloud(false);
    return message;
  }

  Future<String?> saveCredentialsinLocal() async {
    _store.savingInLocal(true);
    final message = await _saveCredentialsinDatabase(Database.local);
    _store.savingInLocal(false);
    return message;
  }

  Future<String?> _saveCredentialsinDatabase(Database database) async {
    final user = await _getLoggedUserUseCase();
    return user.fold(
      (user) async {
        final saved = await _saveSicoobApiCredentialsUseCase(
          database: database,
          id: user.id,
          sicoobApiCredentialsEntity: SicoobApiCredentialsEntity(
            clientID: clientIDController.text,
            certificatePassword: certificatePasswordController.text,
            certificateBase64String: certificateString,
            isFavorite: false,
          ),
        );
        saved.fold(
          (success) => null,
          (failure) => failure.message,
        );
        return null;
      },
      (error) {
        return error.message;
      },
    );
  }

  void clearStore() {
    _store.savingInCloud(false);
    _store.savingInLocal(false);
    _store.validatingCredentials(false);
    _store.setCertificateFileName('');
    _store.setValidFields(false);
  }
}
