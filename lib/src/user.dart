import 'dart:async';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/user_role.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HexabaseUser extends HexabaseBase {
  late String? id;
  late String? name;
  late String? email;
  late String? profilePicture;
  late HexabaseWorkspace? currentWorkspace;
  late List<HexabaseUserRole> roles = [];
  late bool isWsAdmin;

  static late SharedPreferences prefs;
  static String tokenName = 'token';

  HexabaseUser({Map<String, dynamic>? params}) : super() {
    if (params != null) sets(params);
  }

  HexabaseUser sets(Map<String, dynamic> params) {
    params.forEach((key, value) => set(key, value));
    return this;
  }

  HexabaseUser set(String key, dynamic value) {
    switch (key) {
      case 'username':
        name = value as String;
        break;
      case 'email':
        email = value as String;
        break;
      case 'profile_pic':
        profilePicture = value as String;
        break;
      case 'current_workspace_id':
        currentWorkspace = HexabaseWorkspace(params: {'id': value as String});
        break;
      case 'user_roles':
        roles = (value as List)
            .map((e) => HexabaseUserRole(params: e as Map<String, dynamic>))
            .toList();
        break;
      case 'is_ws_admin':
        isWsAdmin = value as String == 'true' || value as bool;
        break;
      case 'id':
      case 'u_id':
        id = value as String;
        break;
      case '__typename':
        break;
      default:
        throw Exception('Invalid field name in HexabaseUser, $key and $value');
    }
    return this;
  }

  static Future<HexabaseUser?> current() async {
    if (HexabaseBase.client.currentUser != null) {
      return HexabaseBase.client.currentUser;
    }
    if (HexabaseBase.client.persistence == Hexabase.persistenceLocal) {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString(tokenName);
      if (token != null) {
        _setJwt(token);
      }
    }
    return HexabaseBase.client.currentUser;
  }

  static Future<bool> login(String email, String password) async {
    final variables = {
      'loginInput': {
        'email': email,
        'password': password,
      },
    };
    final response = await HexabaseBase.mutation(GRAPHQL_LOGIN,
        variables: variables, auth: false);
    return setToken(response.data!['login']?['token']);
  }

  Future<bool> logout() async {
    if (HexabaseBase.client.persistence == Hexabase.persistenceLocal) {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(tokenName)) {
        await prefs.remove(tokenName);
      }
    }
    HexabaseBase.client.currentUser = null;
    try {
      await HexabaseBase.mutation(GRAPHQL_LOGOUT);
    } catch (e) {
      // ignore
    }
    HexabaseBase.client.token = null;
    return true;
  }

  static Future<bool> loginAuth0(String token) async {
    final variables = {
      'auth0Input': {
        'token': token,
      },
    };
    final response =
        await HexabaseBase.mutation(GRAPHQL_LOGIN_AUTH0, variables: variables);
    return setToken(response.data?['loginAuth0']?['token']);
  }

  static Future<bool> setToken(String token) async {
    if (Hexabase.persistenceLocal == HexabaseBase.client.persistence) {
      prefs = await SharedPreferences.getInstance();
      prefs.setString(tokenName, token);
    }
    _setJwt(token);
    return true;
  }

  Future<bool> fetch() async {
    final response = await HexabaseBase.query(GRAPHQL_USER_INFO);
    if (response.data != null && response.data!['userInfo'] != null) {
      sets(response.data!['userInfo'] as Map<String, dynamic>);
      return true;
    }
    return false;
  }

  static void _setJwt(String token) {
    HexabaseBase.client.token = token;
    Map<String, dynamic> payload = Jwt.parseJwt(token);
    HexabaseBase.client.expiryDate = Jwt.getExpiryDate(token)!;
    final user = HexabaseUser();
    user.id = payload['sub'];
    user.name = payload['un'];
    HexabaseBase.client.currentUser = user;
    HexabaseBase.client.init();
  }
}
