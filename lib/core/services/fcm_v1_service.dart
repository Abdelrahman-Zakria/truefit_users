import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class FcmV1Service {
  static const _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
  ];

  // Service Account Credentials Map
  static Map<String, dynamic>? serviceAccountCredentials;

  static Map<String, dynamic>? get _effectiveCredentials {
    if (serviceAccountCredentials != null) {
      return serviceAccountCredentials;
    }
    const envJsonStr = String.fromEnvironment('FCM_SERVICE_ACCOUNT_JSON');
    if (envJsonStr.isNotEmpty) {
      try {
        // Attempt base64 decoding first (standard for Codemagic environment variables)
        final decodedStr = utf8.decode(base64.decode(envJsonStr));
        return jsonDecode(decodedStr) as Map<String, dynamic>;
      } catch (_) {
        try {
          return jsonDecode(envJsonStr) as Map<String, dynamic>;
        } catch (e) {
          debugPrint("Error parsing FCM_SERVICE_ACCOUNT_JSON from environment: $e");
        }
      }
    }
    return null;
  }

  static Future<String?> _getAccessToken() async {
    final creds = _effectiveCredentials;
    if (creds == null) return null;
    try {
      final accountCredentials = auth.ServiceAccountCredentials.fromJson(creds);
      final client = await auth.clientViaServiceAccount(
        accountCredentials,
        _scopes,
      );

      final String accessToken = client.credentials.accessToken.data;
      client.close();

      return accessToken;
    } catch (e) {
      debugPrint("Error generating OAuth2 access token for FCM v1: $e");
      return null;
    }
  }

  static Future<void> sendNotification({
    required String targetToken,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      final creds = _effectiveCredentials;
      final String? accessToken = await _getAccessToken();
      final String projectId = creds?['project_id'] ?? 'true-fit-52715';

      if (accessToken == null || targetToken.isEmpty) return;

      final Uri url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      );

      final Map<String, dynamic> messagePayload = {
        'message': {
          'token': targetToken,
          'notification': {
            'title': title,
            'body': body,
          },
          if (data != null) 'data': data,
        }
      };

      final http.Response response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(messagePayload),
      );

      debugPrint('FCM HTTP v1 Response status: ${response.statusCode}');
      debugPrint('FCM HTTP v1 Response body: ${response.body}');
    } catch (e) {
      debugPrint('Error sending FCM HTTP v1 notification: $e');
    }
  }
}
