import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String? _cachedToken;
  static DateTime? _tokenExpiry;

  static Future<String?> getAccessToken() async {
    final now = DateTime.now();

    //print('Checking token: ');

    // Return cached token if it's still valid
    if (_cachedToken != null &&
        _tokenExpiry != null &&
        now.isBefore(_tokenExpiry!)) {
      // print('The token is valid');
      // print(_cachedToken);
      return _cachedToken;
    }

    //print('Invalid token, creating new...');
    // Request a new token
    final uid = dotenv.env['API_UID'];
    final secret = dotenv.env['API_SECRET'];

    try {
      final response = await http.post(
        Uri.parse('https://api.intra.42.fr/oauth/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'client_credentials',
          'client_id': uid,
          'client_secret': secret,
        },
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _cachedToken = data['access_token'];

        final expiresIn = data['expires_in'] as int;
        _tokenExpiry = now.add(Duration(seconds: expiresIn - 30));
        // _tokenExpiry = now.add(Duration(seconds: 5));
        return _cachedToken;
      } else {
        print('Token request failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('getAccessToken error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchUserProfile(
      String login, String token) async {
    final url = 'https://api.intra.42.fr/v2/users/$login';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      return null;
    } catch (e) {
      print('fetchUserProfile error: $e');
      return null;
    }
  }
}
