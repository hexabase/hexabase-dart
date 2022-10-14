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
    var workspaces =
        response.data?['workspaces']?['workspaces'] as List<Object?>;
    return workspaces.map((workspace) {
      workspace = workspace as Map<String, dynamic>;
      return HexabaseWorkspace(
          id: workspace['workspace_id'], name: workspace['workspace_name']);
    }).toList();
  }

  HexabaseProject project(String id) {
    return HexabaseProject(id: id);
  }

  Future<List<HexabaseProject>> projects() async {
    return HexabaseProject.all(id!);
  }
}
