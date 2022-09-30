import 'dart:async';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';

class HexabaseUser extends HexabaseBase {
  HexabaseUser() : super();

  static Future<bool> login(String email, String password) async {
    final Map<String, Map<String, String>> variables = {
      'loginInput': {
        'email': email,
        'password': password,
      },
    };
    final response = await HexabaseBase.mutation(GRAPHQL_LOGIN,
        variables: variables, auth: false);
    HexabaseBase.client.token = response.data?['login']?['token'];
    HexabaseBase.client.init();
    return true;
  }

  static Future<bool> loginAuth0(String token) async {
    final Map<String, Map<String, String>> variables = {
      'auth0Input': {
        'token': token,
      },
    };
    final response =
        await HexabaseBase.mutation(GRAPHQL_LOGIN_AUTH0, variables: variables);
    HexabaseBase.client.token = response.data?['loginAuth0']?['token'];
    HexabaseBase.client.init();
    return true;
  }
}
