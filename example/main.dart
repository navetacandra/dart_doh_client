import 'package:simple_doh_client/simple_doh_client.dart';

void main(List<String> arguments) async {
  final DoHClient doHClient = DoHClient(provider: DoHProvider.cloudflare);
  final response = await doHClient.get(Uri.parse('https://google.com'));
  print(response.statusCode);
}
