import 'dart:async';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';

class HexabaseWorkspace extends HexabaseBase {
  late String? name;
  late String? id;

  HexabaseWorkspace({Map<String, dynamic>? params}) : super() {
    if (params != null) sets(params);
  }

  Future<bool> save() async {
    if (id == null) return create();
    throw Exception('Workspace does not support update');
  }

  Future<bool> create() async {
    final response =
        await HexabaseBase.query(GRAPHQL_CREATE_WORKSPACE, variables: {
      'createWorkSpaceInput': {
        'name': name,
      }
    });
    sets(response.data as Map<String, dynamic>);
    return true;
  }

  HexabaseWorkspace sets(Map<String, dynamic> params) {
    params.forEach((key, value) => set(key, value));
    return this;
  }

  HexabaseWorkspace set(String key, dynamic value) {
    switch (key) {
      case 'name':
      case 'workspace_name':
        name = value as String;
        break;
      case 'w_id':
      case 'workspace_id':
        id = value as String;
        break;
      case '__typename':
        break;
      default:
        throw Exception("Invalid field name, $key");
    }
    return this;
  }

  static Future<List<HexabaseWorkspace>> all() async {
    final response = await HexabaseBase.query(GRAPHQL_WORKSPACES);
    var workspaces =
        response.data?['workspaces']?['workspaces'] as List<Object?>;
    return workspaces.map((workspace) {
      return HexabaseWorkspace(params: workspace as Map<String, dynamic>);
    }).toList();
  }

  static Future<HexabaseWorkspace> current(String? id) async {
    final response =
        await HexabaseBase.query(GRAPHQL_SELECT_WORKSPACE, variables: {
      'setCurrentWorkSpaceInput': {
        'workspace_id': id,
      }
    });
    final result = response.data?['setCurrentWorkSpace']?['success'] as bool?;
    if (result == null || result == false) {
      throw Exception('Not Found Workspace');
    }
    return HexabaseWorkspace(params: {'workspace_id': id});
  }

  Future<HexabaseProject> project({String? id}) async {
    if (id == null) {
      return HexabaseProject(params: {'workspace': this});
    }
    var project = HexabaseProject(params: {'id': id, 'workspace': this});
    await project.fetch();
    return project;
  }

  Future<List<HexabaseProject>> projects() async {
    return HexabaseProject.all(id!);
  }
}
