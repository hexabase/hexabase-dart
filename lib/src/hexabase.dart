import 'dart:async';
import 'package:graphql/client.dart';
import 'package:hexabase/hexabase.dart';

import 'package:hexabase/src/user.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/workspace.dart';

class Hexabase {
  static late Hexabase _instance;
  final HexabaseEnv env;
  late HexabaseUser auth;
  late HexabaseWorkspace _workspace;
  late HexabaseProject _project;
  String? token;
  late HexabaseUser currentUser;
  late DateTime expiryDate;
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
    _project = HexabaseProject();
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

  Future<bool> isLogin() async {
    // TODO: Check token's validity
    return token != null;
  }

  HexabaseWorkspace workspace({String? id}) {
    return HexabaseWorkspace(id: id);
  }

  Future<List<HexabaseWorkspace>> workspaces() {
    return _workspace.all();
  }

  HexabaseProject project({String? id}) {
    return HexabaseProject(id: id);
  }

  String getEndpoint() {
    if (env == HexabaseEnv.staging) {
      return 'https://hxb-graph.hexabase.com/graphql';
    } else {
      return 'https://graphql.hexabase.com/graphql';
    }
  }

  String getRestEndPoint() {
    if (env == HexabaseEnv.staging) {
      return 'https://az-api.hexabase.com';
    } else {
      return 'https://api.hexabase.com';
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
