import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

class PushNotificationService {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "mazo-4ea7b",
      "private_key_id": "4472b4415795d3053ed6c48d6bf91e8e2700fc18",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDRuOyNIiYSKcmS\nbENuGpyH83KTNCVyUJfFUQjlgh9djCq64TDex7HMmKiFDvg3MgGU9px0tc6q7YHx\nN1sBYrtj0yCI03jE6LPmeWfnxr+zrmJya/rF9A0mPNBVddDCXmpAN4mr/s9rZXIX\nrG16ACYooCMfJE73DobyDg+Rq/T6HLMgnMxyyZ1tVSief2T40h0R4x58eo7eHme9\nTgCDYszL2Em9QNWDAmquokRdV840OqYLOuY56ORpqBnHrZXCJLRy4NwvdqoS+9xo\nVrX6mIYK3c+wgwxesAjj/IKNIoUEQH8UnYy+3JaVBBxNH36Yw//9k3MMf7soGkyK\nQuALbcnpAgMBAAECggEABqRIHYoc0YtwPkpeclC2b1nG4aGPpAioXc/cq8QMsT48\npjF2hj+lwlh9UcVxF/Jl+W079DhDxMcDy/tYTvls/NLVX2/vDbFe7SggIcd6D7sw\nk/YWeYlqlzDq2iICi/1IeSMpIYDO2dRbIiPMTcZObw/vPM++DnXv0R+f35mmBvuu\nAZkIeUX26+Sx/8+72Dwq6id4mnZfYNb3rY0RFsvV4VIQSwoF5hey+3wjRJ8XtpnS\njlkldrdT/SMZLrehNPOQpQKeXU8Whnt3s7WSlBjn35rdYi+P88GUME2LUHBRtgpT\nc21jDq+uou+hamq0JtA+kB6OuM+lhFJUFPrblQ03rwKBgQDydSCpcVdeTlQkYD5O\nWZ1q1HNj1mCkZLEu5D4oDPaAmrU3qSEwsI542kIk01iwPvU2+3PrpzzAUHl5x9QB\nNlw9ghvsIEZEpPCU2j2shXeL2TZUT/SkTqGd0x/F9PoZacXKuPbhZ7JRC1G6bcfP\n7LWS0kf8KrwDAKVksid5utaV+wKBgQDdb7hR1qdScSLzCTAMNATCPCfJtHlHwfjI\nioX92kd1LztqwAac2iZaJ91JMoBXCtoa+1bCWFtDjim2p94HrWwhRNt2ouYp6Gbm\ntVlTQgE4S9XcUbM1JOXIg2t+H3MWJL48f5BoWxUj2bbHgHn2pB0O0/PZJDONPAMx\nz/lJlj4uawKBgCJNX+mZF3tIKa9bznTXSOYsWIbvdYzMkiTINeMEsntPaAQP8Zop\n4H5IosMDA7ErtxWoTaYxau7qc8U++EeToUkydzDZABgGHeNxXPhjiZ5HhOA4z6vP\nVB44GG6xUhD2Xf1oXcVWHmxI5a8yiOpp2uaCyZxrj139YWj1q5AVVvaxAoGACExf\ng/GfY5+Jx8HYYxyv8PeAJjb1NJM4V4uZaeH8O5ABkgaQOOCT/1zvFgcmeByX/9rb\nbX0SLn3tYkL4NyFwo+6IqvF/3qIu+QZiypP2p71vzknhhWRUmCcUqC1Visblui6t\noruHF0jZaLCP4YZU8HFQ+ho5NFnDZOJ+XRucSPECgYBANxPy6NTMxTpNa7/ifXEI\nDoD6aiR2K4Oy2fVGN8pfNPLGS1/CfhborosGvHdXAZPgMmYR+KLz7C+Qa2dil5jA\n7AoSBXAqf12mr+wqbslJQgyjGzxkvEjb+0jS4h4HJvUR+916SDg6YLI1Q/6gTp2z\n6Pd9th13xG4levfZgb2Arw==\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-fbsvc@mazo-4ea7b.iam.gserviceaccount.com",
      "client_id": "105440569239660915144",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40mazo-4ea7b.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com",
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    final httpClient = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    final credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      httpClient,
    );

    httpClient.close();
    return credentials.accessToken.data;
  }

  static Future<void> sendNotificationToUser(
    String deviceToken,
    String title,
    String body,
  ) async {
    final String accessToken = await getAccessToken();

    final String endPoint =
        'https://fcm.googleapis.com/v1/projects/mazo-4ea7b/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {'title': title, 'body': body},
        'webpush': {
          'notification': {
            'title': title,
            'body': body,
            'icon': 'https://mazo.com/icon.png', // اختياري
          },
        },
      },
    };

    final dio = Dio();

    try {
      final response = await dio.post(
        endPoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
        data: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('✅ FCM message sent successfully!');
      } else {
        print('❌ Failed to send FCM message: ${response.statusCode}');
        print(response.data);
      }
    } catch (e) {
      print('❌ Error sending FCM message with Dio: $e');
    }
  }
}
