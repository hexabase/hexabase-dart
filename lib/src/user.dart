import 'dart:async';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HexabaseUser extends HexabaseBase {
  late String? id;
  late String? name;
  static late SharedPreferences prefs;
  static String tokenName = 'token';

  HexabaseUser() : super();

  static Future<HexabaseUser?> getCurrentUser() async {
    if (HexabaseBase.client.currentUser != null) {
      return HexabaseBase.client.currentUser;
    }
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(tokenName);
    if (token != null) {
      _setJwt(token);
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
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(tokenName)) {
      await prefs.remove(tokenName);
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
