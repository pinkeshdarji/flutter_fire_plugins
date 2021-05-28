import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fire_plugins/screens/home.dart';
import 'package:flutter_fire_plugins/utils/authentication.dart';
import 'package:flutter_fire_plugins/utils/database.dart';

class GoogleSignInButton extends StatefulWidget {
  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  Database database = Database();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ElevatedButton(
          onPressed: () async {
            User? user = await Authentication.signInWithGoogle();

            if (user != null) {
              database.storeUserData(user: user);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => Home(
                    user: user,
                  ),
                ),
              );
            }
          },
          child: Text('Sign in with Google'),
        ));
  }
}
