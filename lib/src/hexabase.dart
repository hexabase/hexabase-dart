import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:hexabase/hexabase.dart';

import 'package:hexabase/src/user.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/workspace.dart';
import 'package:hexabase/src/env.dart';

class Hexabase {
  static late Hexabase _instance;
  final HexabaseEnv env;
  late HexabaseUser auth;
  late HexabaseWorkspace _workspace;
  late HexabaseApplication _application;
  String? token;
  late GraphQLClient graphQLClient;
  bool _initialized = false;

  static Hexabase get instance {
    assert(
      _instance._initialized,
      'You must initialize the Hexabase instance before calling Hexabase.instance',
    );
    return _instance;
  }

  Hexabase({this.env = HexabaseEnv.production}) {
    HexabaseBase.client = this;
    auth = HexabaseUser();
    _workspace = HexabaseWorkspace();
    _application = HexabaseApplication();
    graphQLClient = GraphQLClient(
      cache: GraphQLCache(),
      link: HttpLink(
        getEndpoint(),
      ),
    );
    _initialized = true;
    Hexabase._instance = this;
  }

  Future<bool> login(String email, String password) {
    return HexabaseUser.login(email, password);
  }

  HexabaseWorkspace workspace({String? id}) {
    return HexabaseWorkspace(id: id);
  }

  Future<List<HexabaseWorkspace>> workspaces() {
    return _workspace.all();
  }

  HexabaseApplication application({String? id}) {
    return HexabaseApplication(id: id);
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
