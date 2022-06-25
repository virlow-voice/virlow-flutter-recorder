import 'dart:async';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'acc_conf.dart';
import '../main.dart';

class AuthServices {
  showAlertDialog(BuildContext context, message) {
    Widget continueButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Warning"),
      content: Text(message),
      actions: [
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> userSignIn(email, pwd, context) async {
    try {
      await Amplify.Auth.signIn(username: email, password: pwd);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    } on AuthException catch (e) {
      showAlertDialog(context, e.message);
    }
  }

  Future<void> userSignUp(givenName, familyName, pwd, email, context) async {
    Map<CognitoUserAttributeKey, String> userAttributes = {
      CognitoUserAttributeKey.email: email,
      CognitoUserAttributeKey.givenName: givenName,
      CognitoUserAttributeKey.familyName: familyName,
    };

    try {
      SignUpResult res = await Amplify.Auth.signUp(
          username: email,
          password: pwd,
          options: CognitoSignUpOptions(userAttributes: userAttributes));
      if (!res.isSignUpComplete) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => OTPConf(email: email)));
      }
    } on AuthException catch (e) {
      showAlertDialog(context, e.message);
    }
  }

  Future<void> signOut(context) async {
    try {
      await Amplify.Auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    } on AuthException catch (e) {
      showAlertDialog(context, e.message);
    }
  }

  Future<void> confUser(email, confcode, context) async {
    try {
      var res = await Amplify.Auth.confirmSignUp(
          username: email, confirmationCode: confcode);
      if (res.isSignUpComplete) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      showAlertDialog(context, e.message);
    }
  }
}
