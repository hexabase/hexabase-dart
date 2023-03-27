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
  HexabaseUser? currentUser;
  late DateTime expiryDate;
  late GraphQLClient graphQLClient;
  bool _initialized = false;

  static int persistenceNone = 0;
  static int persistenceLocal = 1;
  int persistence = Hexabase.persistenceNone;

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

  Future<bool> loginAuth0(String token) {
    return HexabaseUser.loginAuth0(token);
  }

  Future<bool> logout() async {
    if (currentUser != null) {
      return currentUser!.logout();
    }
    return true;
  }

  Future<bool> setToken(String token) {
    return HexabaseUser.setToken(token);
  }

  Future<HexabaseUser?> getCurrentUser() {
    return HexabaseUser.getCurrentUser();
  }

  Future<bool> isLogin() async {
    try {
      await getCurrentUser();
      await workspaces();
    } catch (e) {
      if (currentUser != null) {
        await currentUser?.logout();
      }
      return false;
    }
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

  Future<List<HexabaseGroup>> groups() {
    return HexabaseGroup.all();
  }

  Future<HexabaseGroup> group({String? id}) async {
    if (id == null) {
      return HexabaseGroup();
    } else {
      return HexabaseGroup.find(id);
    }
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

  String getSSEEndPoint() {
    if (env == HexabaseEnv.staging) {
      return 'https://az-sse.hexabase.com';
    } else {
      return 'https://sse.hexabase.com';
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
