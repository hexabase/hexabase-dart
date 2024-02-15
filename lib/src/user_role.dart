import 'dart:async';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HexabaseUserRole extends HexabaseBase {
  late HexabaseUser user;
  late String roleId;
  late String name;
  late String id;

  HexabaseUserRole({Map<String, dynamic>? params}) : super() {
    if (params != null) sets(params);
  }

  HexabaseUserRole sets(Map<String, dynamic> params) {
    params.forEach((key, value) => set(key, value));
    return this;
  }

  HexabaseUserRole set(String key, dynamic value) {
    switch (key) {
      case 'r_id':
        id = value as String;
        break;
      case 'role_name':
        name = value as String;
        break;
      case 'role_id':
        roleId = value as String;
        break;
      case 'user':
        user = value as HexabaseUser;
        break;
      case '__typename':
      case 'p_id':
      case 'application_id':
      case 'application_name':
      case 'application_display_order':
        break;
    }
    return this;
  }
}
