import 'dart:async';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';

class HexabaseWorkspace extends HexabaseBase {
  late String? name;
  late String? id;

  HexabaseWorkspace({this.id, this.name}) : super();

  Future<List<HexabaseWorkspace>> all() async {
    final response = await query(GRAPHQL_WORKSPACES);
    var workspaces =
        response.data?['workspaces']?['workspaces'] as List<Object?>;
    return workspaces.map((workspace) {
      workspace = workspace as Map<String, dynamic>;
      var id = workspace.containsKey('workspace_id')
          ? workspace['workspace_id']
          : '';
      var name = workspace.containsKey('workspace_name')
          ? workspace['workspace_name']
          : '';
      return HexabaseWorkspace(id: id, name: name);
    }).toList();
  }
}
