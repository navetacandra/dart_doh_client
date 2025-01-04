import 'package:simple_doh_client/simple_doh_client.dart';

void main() async {
  final response = await DoHClient.get(Uri.parse('https://google.com'));
  print(response.statusCode);
}
