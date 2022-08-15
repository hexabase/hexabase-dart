import 'dart:async';
import 'package:graphql/client.dart';

import 'package:hexabase/src/auth.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/workspace.dart';
import 'package:hexabase/src/env.dart';

class HexabaseClient {
  final HexabaseEnv env;
  late HexabaseAuth auth;
  late HexabaseWorkspace workspace;
  late String token;
  late GraphQLClient graphQLClient;

  HexabaseClient({this.env = HexabaseEnv.production}) {
    HexabaseBase.client = this;
    auth = HexabaseAuth();
    workspace = HexabaseWorkspace();
    graphQLClient = GraphQLClient(
      cache: GraphQLCache(),
      link: HttpLink(
        getEndpoint(),
      ),
    );
  }

  String getEndpoint() {
    if (env == HexabaseEnv.staging) {
      return 'https://hxb-graph.hexabase.com/graphql';
    } else {
      return 'https://graphql.hexabase.com/graphql';
    }
  }

  void init() {
    final httpLink = HttpLink(HexabaseBase.client.getEndpoint());
    final authLink = AuthLink(
      getToken: () async => 'Bearer ${HexabaseBase.client.token}',
    );
    Link link = authLink.concat(httpLink);
    graphQLClient = GraphQLClient(cache: GraphQLCache(), link: link);
  }
}
