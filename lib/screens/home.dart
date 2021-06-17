import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fire_plugins/utils/authentication.dart';
import 'package:flutter_fire_plugins/utils/database.dart';

import 'login.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late User _user;
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();
  Database _datebase = Database();
  int _jumpCount = 0;
  late Animation<Offset> boyAnimation;
  late Animation<Offset> girlAnimation;
  late AnimationController boyAnimationController;
  late AnimationController girlAnimationController;

  @override
  void initState() {
    _user = widget._user;
    super.initState();
    boyAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    girlAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    boyAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(0, -1.2))
        .animate(CurvedAnimation(
            parent: boyAnimationController, curve: Curves.easeOut))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              boyAnimationController.reverse();
            }
          });
    girlAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(0, -1.2))
        .animate(CurvedAnimation(
            parent: girlAnimationController, curve: Curves.easeOut))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              girlAnimationController.reverse();
            }
          });
  }

  Future<void> _fetchLatestRemoteConfig(RemoteConfig remoteConfig) async {
    Future.delayed(Duration(seconds: 3), () async {
      try {
        // Using zero duration to force fetching from remote server.
        await remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ));
        await remoteConfig.fetchAndActivate();
      } on PlatformException catch (exception) {
        // Fetch exception.
        print(exception);
      } catch (exception) {
        print('Unable to fetch remote config. Cached or default values will be '
            'used');
        print(exception);
      }
    });
  }

  @override
  void dispose() {
    boyAnimationController.dispose();
    girlAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: FutureBuilder<RemoteConfig>(
                  future: _datebase.setupRemoteConfig(),
                  builder: (BuildContext context,
                      AsyncSnapshot<RemoteConfig> snapshot) {
                    if (snapshot.hasData) {
                      _fetchLatestRemoteConfig(snapshot.requireData);
                      return Image.asset(
                        snapshot.requireData.getString('background') ==
                                'mountains'
                            ? 'assets/images/green_background.png'
                            : 'assets/images/beach.png',
                        fit: BoxFit.fill,
                      );
                    } else {
                      return Image.asset(
                        'assets/images/green_background.png',
                        fit: BoxFit.fill,
                      );
                    }
                  },
                ),
              ),
              Image.asset(
                'assets/images/trempoline.png',
                fit: BoxFit.fill,
              ),
              Positioned(
                left: 170,
                bottom: 50,
                child: Align(
                  alignment: AlignmentDirectional(0.0, 0.7),
                  child: SlideTransition(
                      position: boyAnimation,
                      child: SizedBox(
                        height: 250,
                        width: 250,
                        child: Image.asset(
                          'assets/images/boy.png',
                          fit: BoxFit.fill,
                        ),
                      )),
                ),
              ),
              Positioned(
                right: 170,
                bottom: 50,
                child: Align(
                  alignment: AlignmentDirectional(0.0, 0.7),
                  child: SlideTransition(
                      position: girlAnimation,
                      child: SizedBox(
                        height: 250,
                        width: 170,
                        child: Image.asset(
                          'assets/images/girl.png',
                          fit: BoxFit.fill,
                        ),
                      )),
                ),
              ),
              Positioned(
                left: 20,
                top: 20,
                child: Container(
                  width: 200,
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5),
                      border: Border.all(width: 1, color: Colors.black)),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _usersStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading");
                      }

                      return Expanded(
                        child: new ListView(
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            return Text(
                              '${(document.data() as Map)['name']} : ${(document.data() as Map)['jumps']}',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  onPressed: () async {
                    _jumpCount++;
                    _datebase.updateJumpCount(
                        user: _user, jumpCount: _jumpCount);
                    if (_user.displayName == 'Pinkesh Darji') {
                      boyAnimationController.forward();
                    } else {
                      girlAnimationController.forward();
                    }
                  },
                  child: Text(
                    'Jump',
                    style: TextStyle(fontSize: 34),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 20,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  onPressed: () async {
                    await Authentication.signOut(context: context);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => SignInScreen()),
                    );
                  },
                  child: Text(
                    'logout',
                    style: TextStyle(fontSize: 34),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
