import 'dart:async';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:jwt_decode/jwt_decode.dart';

class HexabaseUser extends HexabaseBase {
  late String? id;
  late String? name;

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
    return init(response.data!['login']?['token']);
  }

  static Future<bool> loginAuth0(String token) async {
    final Map<String, Map<String, String>> variables = {
      'auth0Input': {
        'token': token,
      },
    };
    final response =
        await HexabaseBase.mutation(GRAPHQL_LOGIN_AUTH0, variables: variables);
    return init(response.data?['loginAuth0']?['token']);
  }

  static Future<bool> init(String token) async {
    HexabaseBase.client.token = token;
    Map<String, dynamic> payload = Jwt.parseJwt(token);
    HexabaseBase.client.expiryDate = Jwt.getExpiryDate(token)!;
    final user = HexabaseUser();
    user.id = payload['sub'];
    user.name = payload['un'];
    HexabaseBase.client.currentUser = user;
    HexabaseBase.client.init();
    return true;
  }
}
