import 'dart:async';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/datastore.dart';
import 'package:hexabase/src/graphql.dart';

class HexabaseWorkspace extends HexabaseBase {
  late String? name;
  late String? id;

  HexabaseWorkspace({this.id, this.name}) : super();

  Future<bool> save() async {
    final response =
        await HexabaseBase.query(GRAPHQL_CREATE_WORKSPACE, variables: {
      'createWorkSpaceInput': {
        'name': name,
      }
    });
    id = response.data!['w_id'] as String;
    return true;
  }

  Future<List<HexabaseWorkspace>> all() async {
    final response = await HexabaseBase.query(GRAPHQL_WORKSPACES);
    var workspaces = response.data?['workspaces']?['workspaces']
        as List<Map<String, String>>;
    return workspaces.map((workspace) {
      return HexabaseWorkspace(
          id: workspace['workspace_id'], name: workspace['workspace_name']);
    }).toList();
  }

  HexabaseApplication application(String id) {
    return HexabaseApplication(id: id);
  }

  Future<List<HexabaseApplication>> applications() async {
    return HexabaseApplication.all(id!);
  }
}
