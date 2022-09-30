import 'dart:async';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/datastore.dart';
import 'package:hexabase/src/graphql.dart';

enum HBAppName { ja, en }

class HexabaseApplication extends HexabaseBase {
  late String? id;
  late Map<HBAppName, String> name;
  late DateTime createdAt;
  late DateTime updatedAt;
  String? templateId;
  String? displayId;
  String? theme;

  late List<HexabaseDatastore> datastores;

  HexabaseApplication({this.id}) : super();

  Future<bool> save() async {
    if (id == null) return create();
    return update();
  }

  Future<bool> create() async {
    Map<String, dynamic> createProjectParams = {
      'name': {'ja': name[HBAppName.ja], 'en': name[HBAppName.en]}
    };
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
      'project_name': {'ja': name[HBAppName.ja], 'en': name[HBAppName.en]},
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

  Future<HexabaseApplication> get(String id) async {
    final response = await HexabaseBase.query(
        GRAPHQL_GET_APPLICATION_PROJECT_ID_SETTING,
        variables: {
          'applicationId': id,
        });
    var application = response.data?['getApplicationProjectIdSetting']
        as Map<String, dynamic>;
    this.id = application.containsKey('id') ? application['id'] as String : '';
    name = application.containsKey('name')
        ? {
            HBAppName.ja: application['name']['ja'] as String,
            HBAppName.en: application['name']['en'] as String,
          }
        : {};
    displayId = application.containsKey('display_id')
        ? application['display_id'] as String
        : '';
    createdAt = application.containsKey('created_at')
        ? DateTime.parse(application['created_at'] as String)
        : DateTime.now();
    updatedAt = application.containsKey('updated_at')
        ? DateTime.parse(application['updated_at'] as String)
        : DateTime.now();
    return this;
  }

  static Future<List<HexabaseApplication>> all(String id) async {
    final response = await HexabaseBase.query(
        GRAPHQL_GET_APPLICATION_AND_DATASTORE,
        variables: {
          'workspaceId': id,
        });
    var ary = response.data!['getApplicationAndDataStore'] as List<dynamic>;
    return ary.map((data) {
      var application = HexabaseApplication(id: data['application_id']);
      application.name = {
        HBAppName.ja: data['name'],
        HBAppName.en: data['name']
      };
      application.displayId = data['display_id'];
      var datastores = data['datastores'] as List<dynamic>;
      application.datastores = datastores.map((data) {
        var datastore = HexabaseDatastore(
            id: data['datastore_id'], projectId: data['application_id']);
        datastore.name = data['name'];
        return datastore;
      }).toList();
      return application;
    }).toList();
  }
}
