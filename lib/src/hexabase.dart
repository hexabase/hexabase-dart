import 'dart:async';
import 'package:graphql/client.dart';

import 'package:hexabase/src/auth.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/workspace.dart';
import 'package:hexabase/src/env.dart';

class Hexabase {
  static late Hexabase _instance;
  final HexabaseEnv env;
  late HexabaseAuth auth;
  late HexabaseWorkspace workspace;
  String? token;
  late GraphQLClient graphQLClient;
  bool _initialized = false;

  static Hexabase get instance {
    assert(
      !_instance._initialized,
      'You must initialize the Hexabase instance before calling Hexabase.instance',
    );
    return _instance;
  }

  Hexabase({this.env = HexabaseEnv.production}) {
    HexabaseBase.client = this;
    auth = HexabaseAuth();
    workspace = HexabaseWorkspace();
    graphQLClient = GraphQLClient(
      cache: GraphQLCache(),
      link: HttpLink(
        getEndpoint(),
      ),
    );
    _initialized = true;
    Hexabase._instance = this;
  }

  String getEndpoint() {
    if (env == HexabaseEnv.staging) {
      return 'https://hxb-graph.hexabase.com/graphql';
    } else {
      return 'https://graphql.hexabase.com/graphql';
    }
  }

  void init() {
    final httpLink = HttpLink(getEndpoint());
    final authLink = AuthLink(
      getToken: () async => 'Bearer $token',
    );
    Link link = authLink.concat(httpLink);
    graphQLClient = GraphQLClient(cache: GraphQLCache(), link: link);
  }
}
