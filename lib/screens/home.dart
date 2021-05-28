import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fire_plugins/utils/database.dart';

import '../utils/authentication.dart';
import 'login.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late User _user;
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();
  Database _datebase = Database();
  int _jumpCount = 0;

  @override
  void initState() {
    _user = widget._user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _user.displayName!,
              style: TextStyle(
                fontSize: 26,
              ),
            ),
            SizedBox(height: 8.0),
            StreamBuilder<QuerySnapshot>(
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
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      return new ListTile(
                        title: Text((document.data() as Map)['name']),
                        subtitle:
                            Text((document.data() as Map)['jumps'].toString()),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                _jumpCount++;
                _datebase.updateJumpCount(user: _user, jumpCount: _jumpCount);
              },
              child: Text('Jump'),
            ),
            ElevatedButton(
              onPressed: () async {
                await Authentication.signOut(context: context);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                );
              },
              child: Text('Log out'),
            )
          ],
        ),
      ),
    );
  }
}
