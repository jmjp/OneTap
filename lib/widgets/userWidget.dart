import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserWidget extends InheritedWidget {
  FirebaseUser user;
  DocumentSnapshot userData;
  UserWidget({Key key, this.child,@required this.user, @required this.userData}) : super(key: key, child: child);

  final Widget child;

  static UserWidget of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(UserWidget)as UserWidget);
  }

  @override
  bool updateShouldNotify( UserWidget oldWidget) {
    return true;
  }
}