import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/project.dart';
import 'package:hexabase/src/graphql.dart';

class HexabaseRole extends HexabaseBase {
  late String id;
  late String name;
  late String displayId;
  late DateTime createdAt;
  late String type;
  late HexabaseProject project;
  late HexabaseDatastore datastore;

  HexabaseRole({Map<String, dynamic>? params}) : super() {
    if (params != null) sets(params);
  }

  HexabaseRole sets(Map<String, dynamic> params) {
    params.forEach((key, value) => set(key, value));
    return this;
  }

  HexabaseRole set(String key, dynamic value) {
    switch (key) {
      case 'name':
        name = value as String;
        break;
      case 'id':
        id = value as String;
        break;
      case 'display_id':
        displayId = value as String;
        break;
      case 'datastore':
        datastore = value as HexabaseDatastore;
        break;
      case 'project':
        project = value as HexabaseProject;
        break;
      case '__typename':
        break;
    }
    return this;
  }
  /*
  static Future<List<HexabaseRole>> all(HexabaseProject project) async {
    final response =
        await HexabaseBase.get('/v1/api/get_project_roles', query: {
      'project_id': project.id!,
    });
    // print(response);
    return [];
  }
  */
}
