import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class PushNotificationService {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "taxiapp-6761d",
      "private_key_id": "23ffd3eb26038b767145365eafae82c555aaed45",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDJbW5+06DT8zPZ\nJJv9mGJv4pJBWg6y1NGg7Wi4+Mr3VWYfQC23YaQJBW13kwaNCbvU0+S73Pdr4T4c\nZLf00AfxsOZ2i/l5lFnFbOWfpEhs1a04Sur4MmgbNLTxkcQQElKjdXCNkRoHjzWb\nQUQxTTuOK29YoPPPIR9jzW0UTC8ZHKJj3+CX3JSOOC4ML+J0SaoXvSMk8qiSOzJ/\nvXz+OSSga2UXaTBZDeYrDpiEjKwvrX1MlgZi10cOUWEz5PP9DgoAZpA4Wl4+Nw5/\nfqaYnPBGIXLEPbCdUQCZJqe1x7lKg0ax3J6Kn6aOJRqKYNOUnPJmoYh1oaRqFuYj\n/1j+Fhw/AgMBAAECggEAQxKki6ju0gUXC8SMCQr4JGee6hIR+OyzDVJg389AztFq\nGxfk4T6rP7HF/N5BfS9zk3Anp4LyBMNRSmUjeGrZalrMs0bzANAsgHg9kkZDM7KH\nZspTqegnEIAhjJtMXUmsqO+PViSuNTwzzooSKhScsz+1aR7XcO6HpFUgcHTZ7hMq\np3/jil04BNZh0geXzSrPHm+0KUlpHVYfGJdR5+CObnB/lkWjgnAyCVGDh7cTmJte\ngBinHEOFylLHfeZCIehlCRsNKmLihXbvA8cLMPsyvcWwQkklvY70e7vkLK/Pn5If\neIueu8inO3tYfpakdMep7Eu1uMhPScUp8fnCZQEyQQKBgQDkwuIhjjTP3RYmPqp+\n4l5KobQpr5Nm7F7/u5AazzEyJQzaxS31W9YsYxKVq0USX36m+sPO7tSbFjH58Uoh\nH70mdVZJCLs/2EYni+AwKu9UUT1GPySlLLSPzvE7JynD5m9OF+PhBKF2UbIiOa6J\nPWwVMGtNMqASbM0qG8sJI/vXXwKBgQDhaVuOeC9rC4B6jFEVYy1O2/QuOTXLl7jK\nM6xQ6et5Gp1ts2397gGhMwJe97O+LqaqW+tmbI3SOZjUmC74iq2t/4yA4mjCctPo\n7QCOMdLGhB5eqEwJtQpDaEOqjxwhe3ja4TAbLUrQPeue9oJGo/SYVE41fARlhGi+\nAE0hPJxHIQKBgQCbkxXqsCWmf7sCg3e8FwL9Sn+WIfvi8TmiPdLBCMtySNQ3LAYX\naT98rFwFQZcV6a/eq4fjAXXBixSt4LUDVexzbTUjMjb2MoVze6MZ3vkopJ9BWMv5\nMTAS5TAVhIrY2aw0tfaaH2YXa3Pz5rqWRxlsR6ORuq42GZxl2MT6EGjDjQKBgQDX\nff6OZC2I23UXMx+tH6RH+JUmv4DDQyfg/qdkr0xy+VO5dUjY8nlSX06L9ag7T6P7\nx2ZzA6JNcMy/qUF2UDWb22u6JzjZdCdMTY8zYURMji/udFxFB3NpX7sYyjmtdLnk\nHlX8FT+pdxjTXnzLBaEnI6mlDgux9XSg9+7EsIoCoQKBgFkzl1EKf2l52hoOfu4G\nXzaO5jvNtP6ZvlNef9jxIV5RYDF8Zwka16Nadf+sAzoE0UqNaQ3O2/XZCvAL7Zi0\nfjncbenxgpfZCMgwdhWmKAFeujKDltmdBs2xOq0Tt013ipcCIUANovAQlJ7lo8AG\nk1TCgFySw76+GP7qr99MG0nt\n-----END PRIVATE KEY-----\n",
      "client_email": "taxiappserviceaccount@taxiapp-6761d.iam.gserviceaccount.com",
      "client_id": "117746046597736650964",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/taxiappserviceaccount%40taxiapp-6761d.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = 
    [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client
    );

    client.close();

    return credentials.accessToken.data;
  }

  static sendNotificationToSelectedDriver(String deviceToken) async {
    final String serverKey = await getAccessToken();
    String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/taxiapp-6761d/messages:send';

    final Map<String, dynamic> message = 
    {
      'message':
      {
        'token': deviceToken,
        'notification':
        {
          'title': 'test',
          'body': 'test body'
        },
        'data':
        {
          
        }
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>
      {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey'
      },
      body: jsonEncode(message),
    );

    if(response.statusCode == 200){
      print('Notification sent');
    }
    else{
      print('notification not sent');
    }
    
  }
}
