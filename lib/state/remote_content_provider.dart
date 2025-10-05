import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../app_config.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final remoteContentProvider = FutureProvider.family.autoDispose<String, String>((
  ref,
  endpoint,
) async {
  final client = ref.watch(httpClientProvider);
  final baseUrl = AppConfig.contentBaseUrl;
  final normalizedEndpoint = endpoint.startsWith('/')
      ? endpoint.substring(1)
      : endpoint;
  final uri = Uri.parse('$baseUrl/$normalizedEndpoint');
  final response = await client.get(uri);
  if (response.statusCode != 200) {
    throw Exception(
      'Failed to load content (${response.statusCode}) from ${uri.toString()}',
    );
  }
  return response.body;
});
