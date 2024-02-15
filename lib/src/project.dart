import 'dart:async';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
// import 'package:hexabase/src/datastore.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:hexabase/src/role.dart';
import 'package:collection/collection.dart';

class HexabaseProject extends HexabaseBase {
  late String id = '';
  late String? name;
  late DateTime createdAt;
  late DateTime updatedAt;
  String? templateId;
  String? displayId;
  int? displayOrder;
  String? theme;
  HexabaseWorkspace? workspace;
  List<HexabaseRole?> _roles = [];

  late List<HexabaseDatastore> _datastores = [];

  HexabaseProject({Map<String, dynamic>? params}) : super() {
    if (params != null) sets(params);
  }

  HexabaseProject sets(Map<String, dynamic> params) {
    params.forEach((key, value) => set(key, value));
    return this;
  }

  HexabaseProject set(String key, dynamic value) {
    switch (key) {
      case 'application_id':
      case 'project_id':
      case 'id':
      case 'p_id':
        id = value as String;
        break;
      case 'name':
      case 'project_name':
        name = value as String;
        break;
      case 'display_id':
        displayId = value as String;
        break;
      case 'created_at':
        createdAt = value as DateTime;
        break;
      case 'updated_at':
        updatedAt = value as DateTime;
        break;
      case 'template_id':
        templateId = value as String;
        break;
      case 'display_order':
        displayOrder = value as int;
        break;
      case 'theme':
        theme = value as String;
        break;
      case "workspace":
        workspace = value as HexabaseWorkspace;
        break;
      case 'w_id':
      case "__typename":
      case "datastores":
        break;
      default:
        throw Exception("Invalid field name, $key");
    }
    return this;
  }

  Future<bool> save() async {
    if (id == '') return create();
    throw Exception('Project does not support update');
    // return update();
  }

  Future<bool> create() async {
    Map<String, dynamic> createProjectParams = {'name': name};
    if (templateId != null) {
      createProjectParams['templateId'] = templateId;
    }
    final response = await HexabaseBase.mutation(
        GRAPHQL_APPLICAION_CREATE_PROJECT,
        variables: {'createProjectParams': createProjectParams});
    id = response.data!['applicationCreateProject']['project_id'] as String;
    return true;
  }

  /*
  Future<bool> update() async {
    Map<String, dynamic> payload = {
      'project_id': id,
      'project_name': name,
    };
    if (displayId != null) {
      payload['project_displayid'] = displayId;
    }
    if (theme != null) {
      payload['theme'] = theme;
    }
    final response = await HexabaseBase.mutation(GRAPHQL_UPDATE_PROJECT_NAME,
        variables: {'payload': payload});
    if (response.data!['updateProjectName']['success']) {
      return true;
    }
    return false;
  }
  */

  Future<bool> delete() async {
    final response =
        await HexabaseBase.mutation(GRAPHQL_DELETE_PROJECT, variables: {
      'payload': {
        'project_id': id,
      }
    });
    if (response.data!['deleteProject']['success']) {
      return true;
    }
    return false;
  }

  Future<bool> fetch() async {
    if (id == '') {
      throw Exception('Project id is not set');
    }
    final response = await HexabaseBase.query(GRAPHQL_GET_PROJECT, variables: {
      'projectId': id,
    });
    if (response.data != null) {
      sets(response.data!['getInfoProject'] as Map<String, dynamic>);
      return true;
    }
    return false;
  }

  HexabaseDatastore datastoreSync({String? id}) {
    if (_datastores.isEmpty) {
      throw Exception('Datastores are not fetched');
    }
    if (id != null) {
      var datastore = _datastores.firstWhereOrNull(
        (datastore) => datastore.id == id,
      );
      if (datastore == null) throw Exception('Datastore $id is not found');
      return datastore;
    }
    return HexabaseDatastore(params: {'project': this});
  }

  Future<HexabaseDatastore> datastore({String? id}) async {
    if (_datastores.isEmpty) {
      await datastores();
    }
    if (id != null) {
      var datastore = _datastores.firstWhereOrNull(
        (datastore) => datastore.id == id,
      );
      if (datastore == null) throw Exception('Datastore $id is not found');
      await datastore.fetch();
      return datastore;
    }
    return HexabaseDatastore(params: {'project': this});
  }

  Future<List<HexabaseDatastore>> datastores(
      {List<HexabaseDatastore>? datastores, bool? refresh}) async {
    if (datastores != null) {
      _datastores = datastores;
    }
    if (_datastores.isEmpty || refresh == true) {
      _datastores = await HexabaseDatastore.all(this);
    }
    return _datastores;
  }

  Future<HexabaseProject> get(String id) async {
    final response = await HexabaseBase.query(
        GRAPHQL_GET_APPLICATION_PROJECT_ID_SETTING,
        variables: {
          'applicationId': id,
        });
    sets(response.data?['getApplicationProjectIdSetting']);
    return this;
  }

  Future<dynamic> function(String functionId,
      {Map<String, dynamic>? params}) async {
    params = params ?? {};
    var data = await HexabaseBase.post(
        '/api/v0/applications/$id/functions/$functionId', params);
    var errors = data['errors'] as List<dynamic>;
    if (errors.isNotEmpty) {
      throw Exception(errors);
    }
    return data['data'];
  }

  Future<List<HexabaseRole>> roles() async {
    if (_roles.isEmpty) {
      _roles = await HexabaseRole.all(this);
    }
    return _roles as List<HexabaseRole>;
  }

  static Future<List<HexabaseProject>> all(String id) async {
    final response = await HexabaseBase.query(
        GRAPHQL_GET_APPLICATION_AND_DATASTORE,
        variables: {
          'workspaceId': id,
        });
    var ary = response.data!['getApplicationAndDataStore'] as List<dynamic>;
    var projects = ary.map((data) {
      var project = HexabaseProject(params: data);
      if (data['datastores'] == null) {
        project._datastores = [];
        return project;
      }
      var datastores = data['datastores'] as List<dynamic>;
      project._datastores = datastores.map((data) {
        (data as Map<String, dynamic>).addAll({'project': project});
        return HexabaseDatastore(params: data);
      }).toList();
      return project;
    }).toList();
    for (var project in projects) {
      for (var datastore in project._datastores) {
        await datastore.fetch();
      }
    }
    return projects;
  }
}
