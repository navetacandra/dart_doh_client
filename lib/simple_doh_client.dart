// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum DoHProvider {
  cloudflare,
  google,
}

String _getDoHUrl(DoHProvider provider) {
  switch (provider) {
    case DoHProvider.google:
      return 'https://dns.google/dns-query';
    case DoHProvider.cloudflare:
      return 'https://mozilla.cloudflare-dns.com/dns-query';
  }
}

Future<void> _ensureDNSAvailable(String _dohUrl) async {
  try {
    final addresses = await InternetAddress.lookup(Uri.parse(_dohUrl).host);
    if (addresses.isEmpty) {
      throw Exception('DNS server unavailable!');
    }
  } catch (e) {
    throw Exception('DNS server unavailable!');
  }
}

class DoHClient {
  static Future<List<String>?> lookup(
    String hostname, {
    DoHProvider provider = DoHProvider.cloudflare,
  }) async {
    final _dohUrl = _getDoHUrl(provider);
    await _ensureDNSAvailable(_dohUrl);

    final response = await http.get(
      Uri.parse('$_dohUrl?name=$hostname&type=A'),
      headers: {
        'Accept': 'application/dns-json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Answer'] != null && data['Answer'].isNotEmpty) {
        return (data['Answer'] as List<dynamic>).map((a) => a['data'] as String).toList();
      }
    }

    return null;
  }

  static Future<http.Response> head(
    Uri url, {
    Map<String, String>? headers,
    DoHProvider provider = DoHProvider.cloudflare,
  }) async {
    final ipAddress = (await lookup(url.host, provider: provider))?.first;
    if (ipAddress == null) throw Exception("Cannot resolve hostname.");

    final _headers = {
      ...(headers ?? {}),
      'Host': url.host,
    };
    return http.head(
      Uri.http(ipAddress, url.path, url.queryParameters),
      headers: _headers,
    );
  }

  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    DoHProvider provider = DoHProvider.cloudflare,
  }) async {
    final ipAddress = (await lookup(url.host, provider: provider))?.first;
    if (ipAddress == null) throw Exception("Cannot resolve hostname.");

    final _headers = {
      ...(headers ?? {}),
      'Host': url.host,
    };
    return http.get(
      Uri.http(ipAddress, url.path, url.queryParameters),
      headers: _headers,
    );
  }

  static Future<http.Response> post(
    Uri url, {
    DoHProvider provider = DoHProvider.cloudflare,
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final ipAddress = (await lookup(url.host, provider: provider))?.first;
    if (ipAddress == null) throw Exception("Cannot resolve hostname.");

    final _headers = {
      ...(headers ?? {}),
      'Host': url.host,
    };
    return http.post(
      Uri.http(ipAddress, url.path, url.queryParameters),
      headers: _headers,
      body: body,
      encoding: encoding,
    );
  }

  static Future<http.Response> put(
    Uri url, {
    DoHProvider provider = DoHProvider.cloudflare,
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final ipAddress = (await lookup(url.host, provider: provider))?.first;
    if (ipAddress == null) throw Exception("Cannot resolve hostname.");

    final _headers = {
      ...(headers ?? {}),
      'Host': url.host,
    };
    return http.put(
      Uri.http(ipAddress, url.path, url.queryParameters),
      headers: _headers,
      body: body,
      encoding: encoding,
    );
  }

  static Future<http.Response> patch(
    Uri url, {
    DoHProvider provider = DoHProvider.cloudflare,
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final ipAddress = (await lookup(url.host, provider: provider))?.first;
    if (ipAddress == null) throw Exception("Cannot resolve hostname.");

    final _headers = {
      ...(headers ?? {}),
      'Host': url.host,
    };
    return http.patch(
      Uri.http(ipAddress, url.path, url.queryParameters),
      headers: _headers,
      body: body,
      encoding: encoding,
    );
  }

  static Future<http.Response> delete(
    Uri url, {
    DoHProvider provider = DoHProvider.cloudflare,
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final ipAddress = (await lookup(url.host, provider: provider))?.first;
    if (ipAddress == null) throw Exception("Cannot resolve hostname.");

    final _headers = {
      ...(headers ?? {}),
      'Host': url.host,
    };
    return http.delete(
      Uri.http(ipAddress, url.path, url.queryParameters),
      headers: _headers,
      body: body,
      encoding: encoding,
    );
  }
}
