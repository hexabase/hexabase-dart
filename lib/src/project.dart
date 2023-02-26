import 'dart:async';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/datastore.dart';
import 'package:hexabase/src/graphql.dart';

class HexabaseProject extends HexabaseBase {
  late String? id;
  late Map<String, String> _name = {};
  late DateTime createdAt;
  late DateTime updatedAt;
  String? templateId;
  String? displayId;
  String? theme;
  HexabaseWorkspace? workspace;

  late List<HexabaseDatastore?> _datastores = [];

  HexabaseProject({this.id, this.workspace}) : super();

  Future<bool> save() async {
    if (id == null) return create();
    return update();
  }

  HexabaseProject name(String language, String name) {
    if (!['ja', 'en'].contains(language)) {
      throw Exception('Language must be ja or en');
    }
    _name[language] = name;
    return this;
  }

  Future<bool> create() async {
    Map<String, dynamic> createProjectParams = {'name': _name};
    if (templateId != null) {
      createProjectParams['templateId'] = templateId;
    }
    final response = await HexabaseBase.mutation(
        GRAPHQL_APPLICAION_CREATE_PROJECT,
        variables: {'createProjectParams': createProjectParams});
    id = response.data!['applicationCreateProject']['project_id'] as String;
    return true;
  }

  Future<bool> update() async {
    Map<String, dynamic> payload = {
      'project_id': id,
      'project_name': _name,
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

  Future<HexabaseDatastore> datastore({String? id}) async {
    if (id != null) {
      var ds = _datastores.firstWhere((datastore) => datastore!.id == id,
          orElse: () => null);
      if (ds == null) throw Exception('Datastore $id is not found');
      return ds;
    }
    var ds = HexabaseDatastore(project: this);
    await ds.save();
    _datastores.add(ds);
    return ds;
  }

  List<HexabaseDatastore> datastores() {
    return _datastores as List<HexabaseDatastore>;
  }

  Future<HexabaseProject> get(String id) async {
    final response = await HexabaseBase.query(
        GRAPHQL_GET_APPLICATION_PROJECT_ID_SETTING,
        variables: {
          'applicationId': id,
        });
    var project = response.data?['getApplicationProjectIdSetting']
        as Map<String, dynamic>;
    this.id = project.containsKey('id') ? project['id'] as String : '';
    _name = project.containsKey('name')
        ? {
            'ja': project['name']['ja'] as String,
            'en': project['name']['en'] as String,
          }
        : {};
    displayId = project.containsKey('display_id')
        ? project['display_id'] as String
        : '';
    createdAt = project.containsKey('created_at')
        ? DateTime.parse(project['created_at'] as String)
        : DateTime.now();
    updatedAt = project.containsKey('updated_at')
        ? DateTime.parse(project['updated_at'] as String)
        : DateTime.now();
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

  static Future<List<HexabaseProject>> all(String id) async {
    final response = await HexabaseBase.query(
        GRAPHQL_GET_APPLICATION_AND_DATASTORE,
        variables: {
          'workspaceId': id,
        });
    var ary = response.data!['getApplicationAndDataStore'] as List<dynamic>;
    return ary.map((data) {
      var project = HexabaseProject(id: data['project_id']);
      project._name = {'ja': data['name'], 'en': data['name']};
      project.displayId = data['display_id'];
      var datastores = data['datastores'] as List<dynamic>;
      project._datastores = datastores.map((data) {
        var datastore =
            HexabaseDatastore(id: data['datastore_id'], project: project);
        datastore.name('ja', data['name'] as String);
        datastore.displayId = data['display_id'] as String;
        datastore.deleted = data['deleted'] as bool;
        datastore.imported = data['imported'] as bool;
        datastore.uploading = data['uploading'] as bool;
        return datastore;
      }).toList();
      return project;
    }).toList();
  }
}
