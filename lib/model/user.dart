import 'package:flutter/material.dart';

class AppUser {
  String? uid;
  String? name;
  int? jumps;

  AppUser({@required this.uid, @required this.name, this.jumps});

  AppUser.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    jumps = json['jumps'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['uid'] = this.uid;
    data['name'] = this.name;
    data['jumps'] = this.jumps;

    return data;
  }
}
