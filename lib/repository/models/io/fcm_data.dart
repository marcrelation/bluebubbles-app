import 'dart:async';

import 'package:bluebubbles/main.dart';
import 'package:bluebubbles/objectbox.g.dart';
import 'package:bluebubbles/repository/models/config_entry.dart';
import 'package:bluebubbles/services/services.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class FCMData {
  int? id;
  String? projectID;
  String? storageBucket;
  String? apiKey;
  String? firebaseURL;
  String? clientID;
  String? applicationID;

  FCMData({
    this.id,
    this.projectID,
    this.storageBucket,
    this.apiKey,
    this.firebaseURL,
    this.clientID,
    this.applicationID,
  });

  factory FCMData.fromMap(Map<String, dynamic> json) {
    Map<String, dynamic> projectInfo = json["project_info"];
    Map<String, dynamic> client = json["client"][0];
    String clientID = client["oauth_client"][0]["client_id"];
    return FCMData(
      projectID: projectInfo["project_id"],
      storageBucket: projectInfo["storage_bucket"],
      apiKey: client["api_key"][0]["current_key"],
      firebaseURL: projectInfo["firebase_url"],
      clientID: clientID.contains("-") ? clientID.substring(0, clientID.indexOf("-")) : clientID,
      applicationID: client["client_info"]["mobilesdk_app_id"],
    );
  }

  factory FCMData.fromConfigEntries(List<ConfigEntry> entries) {
    FCMData data = FCMData();
    for (ConfigEntry entry in entries) {
      if (entry.name == "projectID") {
        data.projectID = entry.value;
      } else if (entry.name == "storageBucket") {
        data.storageBucket = entry.value;
      } else if (entry.name == "apiKey") {
        data.apiKey = entry.value;
      } else if (entry.name == "firebaseURL") {
        data.firebaseURL = entry.value;
      } else if (entry.name == "clientID") {
        data.clientID = entry.value;
      } else if (entry.name == "applicationID") {
        data.applicationID = entry.value;
      }
    }
    return data;
  }

  FCMData save() {
    if (kIsWeb) return this;
    fcmDataBox.put(this);
    return this;
  }

  static void deleteFcmData() {
    fcmDataBox.removeAll();
    settings.prefs.remove('projectID');
    settings.prefs.remove('storageBucket');
    settings.prefs.remove('apiKey');
    settings.prefs.remove('firebaseURL');
    settings.prefs.remove('clientID');
    settings.prefs.remove('applicationID');
  }

  static Future<void> initializeFirebase(FCMData data) async {
    var options = FirebaseOptions(
      appId: data.applicationID!,
      apiKey: data.apiKey!,
      projectId: data.projectID!,
      storageBucket: data.storageBucket,
      databaseURL: data.firebaseURL,
      messagingSenderId: data.clientID,
    );
    app = await Firebase.initializeApp(options: options);
  }

  static FCMData getFCM() {
    final result = fcmDataBox.getAll();
    if (result.isEmpty) {
      return FCMData(
        projectID: settings.prefs.getString('projectID'),
        storageBucket: settings.prefs.getString('storageBucket'),
        apiKey: settings.prefs.getString('apiKey'),
        firebaseURL: settings.prefs.getString('firebaseURL'),
        clientID: settings.prefs.getString('clientID'),
        applicationID: settings.prefs.getString('applicationID'),
      );
    }
    return result.first;
  }

  Map<String, dynamic> toMap() => {
        "project_id": projectID,
        "storage_bucket": storageBucket,
        "api_key": apiKey,
        "firebase_url": firebaseURL,
        "client_id": clientID,
        "application_id": applicationID,
      };

  bool get isNull =>
      projectID == null ||
      storageBucket == null ||
      apiKey == null ||
      firebaseURL == null ||
      clientID == null ||
      applicationID == null;
}
