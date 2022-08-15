import 'dart:async';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';

class HexabaseAuth extends HexabaseBase {
  HexabaseAuth() : super();

  Future<bool> signIn(String email, String password) async {
    final Map<String, dynamic> variables = {
      'loginInput': {
        'email': email,
        'password': password,
      },
    };
    final response = await mutation(GRAPHQL_LOGIN, variables: variables);
    HexabaseBase.client.token = response.data?['login']?['token'];
    HexabaseBase.client.init();
    return false;
  }
}
