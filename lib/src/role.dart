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
  HexabaseProject project;

  HexabaseRole(this.project) : super();

  static Future<List<HexabaseRole>> all(HexabaseProject project) async {
    final response =
        await HexabaseBase.get('/v1/api/get_project_roles', query: {
      'project_id': project.id!,
    });
    print(response);
    return [];
  }
}
