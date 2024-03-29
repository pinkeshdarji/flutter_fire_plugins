import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_fire_plugins/model/user.dart';

class Database {
  static final Database _singleton = Database._internal();

  factory Database() {
    return _singleton;
  }

  Database._internal();

  /// The main Firestore user collection
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  storeUserData({required User user}) async {
    AppUser appUser = AppUser(uid: user.uid, name: user.displayName, jumps: 0);

    await userCollection
        .doc(user.uid)
        .set(appUser.toJson())
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  updateJumpCount({required User user, required int jumpCount}) async {
    await userCollection
        .doc(user.uid)
        .update({'jumps': jumpCount})
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<RemoteConfig> setupRemoteConfig() async {
    await Firebase.initializeApp();
    final RemoteConfig remoteConfig = RemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ));
    await remoteConfig
        .setDefaults(<String, dynamic>{'background': 'mountains'});
    RemoteConfigValue(null, ValueSource.valueStatic);
    return remoteConfig;
  }
}
