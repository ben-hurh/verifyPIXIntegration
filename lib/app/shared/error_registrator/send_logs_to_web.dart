// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:verify/app/shared/error_registrator/discord_webhook_url.dart';
import 'package:verify/app/shared/services/client_service/client_service.dart';

abstract class SendLogsToWeb {
  Future<void> call(Object e);
}

class SendLogsToDiscordChannel implements SendLogsToWeb {
  final ClientService _clientService;
  SendLogsToDiscordChannel(
    this._clientService,
  );
  @override
  Future<void> call(Object e) async {
    await _clientService.post(
      url: discordWebookUrl,
      body: {'content': '```Error: $e```'},
    );
  }
}
