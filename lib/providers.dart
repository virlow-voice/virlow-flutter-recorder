import 'package:flutter/material.dart';

class UserLoginStatus with ChangeNotifier {
  UserLoginStatus({required this.userLoggedIn});

  bool userLoggedIn;

  changeUserStatus(bool changeState) {
    userLoggedIn = changeState;
    notifyListeners();
    // printNewSelection();
  }
}

class CurrUser with ChangeNotifier {
  CurrUser({required this.awsUser});

  var awsUser;

  changeUser(var newUser) {
    awsUser = newUser;
    notifyListeners();
  }
}
