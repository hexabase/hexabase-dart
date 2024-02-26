import 'dart:async';
import 'package:graphql/client.dart';
import 'package:hexabase/hexabase.dart';

import 'package:hexabase/src/user.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/workspace.dart';
import 'package:signalr_netcore/signalr_client.dart';

import 'graphql.dart';

class Hexabase {
  static late Hexabase _instance;
  final HexabaseEnv env;
  // late HexabaseUser auth;
  late List<HexabaseWorkspace> _workspaces = [];
  String? token;
  HexabaseUser? currentUser;
  late DateTime expiryDate;
  late GraphQLClient graphQLClient;
  bool _initialized = false;
  late HexabaseWorkspace currentWorkspace;

  static int persistenceNone = 0;
  static int persistenceLocal = 1;
  int persistence = Hexabase.persistenceNone;

  late String graphQLUrl;
  late String restUrl;
  late String pubSubUrl;
  HubConnection? hubConnection = null;
  int connectionCount = 0;

  static Hexabase get instance {
    assert(
      _instance._initialized,
      'You must initialize the Hexabase instance before calling Hexabase.instance',
    );
    return _instance;
  }

  Hexabase(
      {this.env = HexabaseEnv.production,
      String? graphQLUrl,
      String? restUrl,
      String? pubSubUrl}) {
    HexabaseBase.client = this;
    if (env == HexabaseEnv.staging) {
      this.graphQLUrl = 'https://stg-hxb-graph.hexabase.com/graphql';
      this.restUrl = 'https://stg-api.hexabase.com';
      this.pubSubUrl = 'https://stg-pubsub.hexabase.com/hub';
    } else {
      this.graphQLUrl = 'https://graphql.hexabase.com/graphql';
      this.restUrl = 'https://api.hexabase.com';
      this.pubSubUrl = 'https://pubsub.hexabase.com/hub';
    }

    if (graphQLUrl != null) {
      this.graphQLUrl = graphQLUrl;
    }
    if (restUrl != null) {
      this.restUrl = restUrl;
    }
    if (pubSubUrl != null) {
      this.pubSubUrl = pubSubUrl;
    }

    // auth = HexabaseUser();
    graphQLClient = GraphQLClient(
      cache: GraphQLCache(),
      link: HttpLink(
        this.graphQLUrl,
      ),
    );
    _initialized = true;
    Hexabase._instance = this;
  }

  Future<bool> login(String email, String password) async {
    if (email == '' || password == '') {
      throw Exception('Email and password are required');
    }
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
    return HexabaseUser.current();
  }

  Future<bool> isLogin() async {
    try {
      var user = await getCurrentUser();
      await user!.fetch();
      await workspaces();
    } catch (e) {
      if (currentUser != null) {
        await currentUser?.logout();
      }
      return false;
    }
    return token != null;
  }

  Future<HexabaseWorkspace> setWorkspace(String workspaceId) async {
    currentWorkspace = await HexabaseWorkspace.current(workspaceId);
    return currentWorkspace;
  }

  HexabaseWorkspace workspace({String? id}) {
    if (id == null) return HexabaseWorkspace();
    return HexabaseWorkspace(params: {'id': id});
  }

  Future<List<HexabaseWorkspace>> workspaces() async {
    if (_workspaces.isNotEmpty) {
      return Future.value(_workspaces);
    }
    _workspaces = await HexabaseWorkspace.all();
    return Future.value(_workspaces);
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

  void init() {
    final httpLink = HttpLink(graphQLUrl);
    final authLink = AuthLink(
      getToken: () async => 'Bearer $token',
    );
    Link link = authLink.concat(httpLink);
    graphQLClient = GraphQLClient(cache: GraphQLCache(), link: link);
  }

  Future<bool> pubSub(String channel, void Function(List<Object?>?) f) async {
    if (hubConnection != null && hubConnection!.connectionId != null) {
      return true;
    }
    try {
      hubConnection =
          HubConnectionBuilder().withUrl(HexabaseBase.client.pubSubUrl).build();
      await hubConnection!.start();
      hubConnection!.on(channel, f);
      connectionCount++;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> unsubscribe(String channel) async {
    if (hubConnection != null) {
      hubConnection!.off(channel);
      connectionCount--;
    }
    if (connectionCount == 0) {
      await hubConnection!.stop();
    }
  }
}
