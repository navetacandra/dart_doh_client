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
  final DoHProvider provider;

  DoHClient({this.provider = DoHProvider.cloudflare});

  static Future<List<String>?> staticLookup(
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

  Future<List<String>?> lookup(String hostname) {
    return DoHClient.staticLookup(hostname, provider: provider);
  }

  Future<String?> _resolveDomain(String hostname) async {
    final lookupResult = await lookup(hostname);
    return lookupResult?.first;
  }

  Future<http.Response> head(Uri url, {Map<String, String>? headers}) async {
    final ipAddress = await _resolveDomain(url.host);
    if (ipAddress == null) throw Exception("Cannot resolve hostname.");

    final _headers = {...(headers ?? {})};
    _headers['Host'] = url.host;

    return http.head(Uri.http(ipAddress, url.path, url.queryParameters), headers: _headers);
  }

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final ipAddress = await _resolveDomain(url.host);
    if (ipAddress == null) throw Exception("Cannot resolve hostname.");

    final _headers = {...(headers ?? {})};
    _headers['Host'] = url.host;
    return http.get(Uri.http(ipAddress, url.path, url.queryParameters), headers: _headers);
  }

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final ipAddress = await _resolveDomain(url.host);
    if (ipAddress == null) throw Exception("Cannot resolve hostname.");

    final _headers = {...(headers ?? {})};
    _headers['Host'] = url.host;
    return http.post(Uri.http(ipAddress, url.path, url.queryParameters), headers: _headers, body: body, encoding: encoding);
  }

  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final ipAddress = await _resolveDomain(url.host);
    if (ipAddress == null) throw Exception("Cannot resolve hostname.");

    final _headers = {...(headers ?? {})};
    _headers['Host'] = url.host;

    return http.put(Uri.http(ipAddress, url.path, url.queryParameters), headers: _headers, body: body, encoding: encoding);
  }

  Future<http.Response> patch(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final ipAddress = await _resolveDomain(url.host);
    if (ipAddress == null) throw Exception("Cannot resolve hostname.");

    final _headers = {...(headers ?? {})};
    _headers['Host'] = url.host;

    return http.patch(Uri.http(ipAddress, url.path, url.queryParameters), headers: _headers, body: body, encoding: encoding);
  }

  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final ipAddress = await _resolveDomain(url.host);
    if (ipAddress == null) throw Exception("Cannot resolve hostname.");

    final _headers = {...(headers ?? {})};
    _headers['Host'] = url.host;

    return http.delete(Uri.http(ipAddress, url.path, url.queryParameters), headers: _headers, body: body, encoding: encoding);
  }
}
